<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@include file="common/header.jsp" %>
            <style>
                .custom-class {
                    table-layout: fixed;
                }

                td {
                    word-wrap: break-word;
                }

                h1 {
                    text-align: center;
                }
            </style>
            
            <h1 class="mt-5">查詢所有專案</h1>

            <div class="w-75">
                <div class="row mb-3">
                    <div class="row">
                        <div class="col">
                            <label class="form-label w-50" for="token">Gitlab Token:</label>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col">
                            <input class="form-control" type="text" id="token" placeholder="請輸入private token..."
                                required>
                        </div>
                        <div class="col-sm-auto">
                            <button class="btn btn-success" onclick="doQuery();">查詢</button>
                            <button class="btn btn-warning" onclick="doReloadData();">更新資料</button>
                        </div>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="row">
                        <div class="col">
                            <label class="form-label" for="keyword">關鍵字:</label>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col">
                            <input class="form-control" type="text" id="keyword" placeholder="請輸入想查詢的關鍵字..." autocomplete="off">
                        </div>
                        <div class="col-sm-auto">
                            <button class="btn btn-success" onclick="doQueryByKeyWord();">關鍵字查詢</button>
                        </div>
                    </div>
                </div>
                <div class="row mb-3">
					<div class="row">
						<div class="col">
							<label class="form-label" for="searchGroup">群組:</label>
						</div>
					</div>
					<div class="col">
                        <input list="groups" class="form-control" type="text" id="searchGroup" placeholder="請輸入想查詢的群組..." oninput="countProjects();" autocomplete="off">
	                    <datalist id="groups"></datalist>
                    </div>
                    <div class="col">
                        <select class="form-select" id="searchGroupSelector" onchange="doChangeGroupSelected();"></select>
                    </div>
                </div>
				<div class="row mb-3">
					<div class="col-auto">
						<div class="row">
							<div class="col-auto ml-12px">專案數：</div>
							<div id="projects_count" class="col"></div>
						</div>
					</div>
				</div>
            </div>
            <!-- 查詢全部專案顯示區塊 -->
            <table id="projectResultTable" class="table custom-class" style="display: none;">
                <thead>
                    <tr>
                        <th scope="col" class="col-1">id</th>
                        <th scope="col" class="col-4">群/名稱</th>
                        <th scope="col" class="col-4">描述</th>
                        <th scope="col" class="col-1">網址</th>
                        <th scope="col" class="col-2">創建時間</th>
                    </tr>
                </thead>
                <tbody id="projectList">
                </tbody>
            </table>
            <!-- 查詢關鍵字顯示區塊 -->
            <table id="keywordResultTable" class="table custom-class" style="display: none;">
                <thead>
                    <tr>
                        <th scope="col" class="col-2">群/專案</th>
                        <th scope="col" class="col-2">檔名</th>
                        <th scope="col" class="col-1"></th>                        
                        <th scope="col" class="col-7">結果</th>
                    </tr>
                </thead>
                <tbody id="resultList">
                </tbody>
            </table>
            <script>
				
            	// 準備好時呼叫初始func
                $(document).ready(function () {
                    init();
                });

            	// 初始func
                function init() {
                    // 將localStorage的token填入input
                    $("#token").val(localStorage.getItem("token"));
                    // 初始化群組清單
                    initSearchGroupSelector();
                }

                /**
                 * 查詢所有專案
                 */
                function doQuery() {
                    if (!$("#token").val()) {
                        Swal.fire({
                            // position: "top-end",
                            icon: "error",
                            title: "必須輸入token",
                            showConfirmButton: false,
                            timer: 1000
                        });
                        return;
                    }

                    $("#projectList").empty();

                    $.ajax({
                        url: "/gitlabhelper/projects",
                        type: "GET",
                        headers: {
                            "private-token": $("#token").val()
                        },
                        data: {
                        },
                        success: function (data) {
                            console.log(data); // debug
                            drawProjectList(data);
                            $("#projectResultTable").show();
                            $("#keywordResultTable").hide();
                            doCacheToken();
                        },
                        error: function (xhr, status, error) {
                            var err = eval("(" + xhr.responseText + ")");
                            Swal.fire({
                                icon: "error",
                                title: "發生錯誤",
                                text: err.Message,
                                showConfirmButton: false,
                                timer: 1000
                            });
                        }
                    });
                }

                function doReloadData() {
                    if (!$("#token").val()) {
                        Swal.fire({
                            icon: "error",
                            title: "必須輸入token",
                            showConfirmButton: false,
                            timer: 1000
                        });
                        return;
                    }

                    $("#projectList").empty();

                    $.ajax({
                        url: "/gitlabhelper/reload",
                        type: "PUT",
                        headers: {
                            "private-token": $("#token").val()
                        },
                        data: {
                        },
                        success: function (data) {
                            doQuery();
                            initSearchGroupSelector();
                            doCacheToken();
                        },
                        error: function (xhr, status, error) {
                            var err = eval("(" + xhr.responseText + ")");
                            Swal.fire({
                                icon: "error",
                                title: "發生錯誤",
                                text: err.Message,
                                showConfirmButton: false,
                                timer: 1000
                            });
                        }
                    });

                }

                // 初始化群組清單(下拉選單 + 輸入框datalist)
                function initSearchGroupSelector() {
                    $.ajax({
                        url: "/gitlabhelper/groupNames",
                        type: "GET",
                        data: {
                        },
                        success: function (data) {
                            console.log(data); // debug
                            drawSearchGroupSelector(data); // 顯示群組下拉選單
                            drawSearchGroupList(data); // 顯示輸入框datalist
                            countProjects();
                        },
                        error: function (xhr, status, error) {
                            var err = eval("(" + xhr.responseText + ")");
                            Swal.fire({
                                icon: "error",
                                title: "發生錯誤",
                                text: err.Message,
                                showConfirmButton: false,
                                timer: 1000
                            });
                        }
                    });
                }

                // 關鍵字查詢
                function doQueryByKeyWord() {
                    if (!$("#keyword").val() || $("#keyword").val().length < 2) {
                        Swal.fire({
                            icon: "error",
                            title: "關鍵字必須輸入兩個字以上",
                            showConfirmButton: false,
                            timer: 1000
                        });
                        return;
                    }

                    $("#resultList").empty();

                    $.ajax({
                        url: "/gitlabhelper/search",
                        type: "GET",
                        headers: {
                            "private-token": $("#token").val()
                        },
                        data:{
                            keyword: $("#keyword").val(),
                            searchGroup: $("#searchGroup").val()
                        },
                        success: function (data) {
                            $("#projectResultTable").hide();
                            console.log(data); // debug
                            drawResultList(data);
                            $("#keywordResultTable").show();
                            hljs.highlightAll(); // 觸發highlight.js 修改CODE顏色
                            highlightSearchText();
                            markSearchTextCode();
                        },
                        error: function (xhr, status, error) {
                            var err = eval("(" + xhr.responseText + ")");
                            Swal.fire({
                                icon: "error",
                                title: "發生錯誤",
                                text: err.Message,
                                showConfirmButton: false,
                                timer: 1000
                            });
                        }
                    });

                }

                // 群組下拉選單變動時，同步更新輸入框 + 專案數
                function doChangeGroupSelected() {
                	let selectedOption = $("#searchGroupSelector").val();
                	$("#searchGroup").val(selectedOption);
                	countProjects();
                }
                
             	// 顯示群組下拉選單
                function drawSearchGroupSelector(data) {
                    $("#searchGroupSelector").empty();
                    $("#searchGroupSelector").append(
                        `<option value="">請選擇群組</option>`)
                    data.forEach(function (groupData) {
                        $("#searchGroupSelector").append(
                            `<option value="\${groupData.group_name}">\${groupData.group_name}\t專案筆數: \${groupData.number}</option>`)
                    })
                }

             	// 顯示輸入框datalist
                function drawSearchGroupList(data) {
                	$("#groups").empty();
                    $("#groups").append(
                        `<option value="">請選擇群組</option>`)
                    data.forEach(function (groupData) {
                        $("#groups").append(
                            `<option value="\${groupData.group_name}" project_num="\${groupData.number}">\${groupData.group_name}\t專案筆數: \${groupData.number}</option>`)
                    })
                }
             	// 顯示所有專案查詢結果
                function drawResultList(data) {
                    $("#resultList").empty();
                    
                    data.forEach((searchResult) => {
                        let infoMessage = '';
                        
                        // 超過結果上限，顯示警告
                        if (searchResult.is_over_limit) {
                            infoMessage = '<b style="color:red;">※ 超過搜尋上限，僅顯示部分資料</b><br>';
                        }

                     	// 防止'<','>'被解析為TAG
                        const originalData = searchResult.data;
                    	let replaceData = originalData.replaceAll("<","&lt;");
                    	replaceData = replaceData.replaceAll(">","&gt;");
                        
                        $("#resultList").append(
                            `<tr><td>\${infoMessage}\${searchResult.full_project_name} </td>
                            <td class='search-result'> \${searchResult.file_name} </td>
                            <td> TODO: 連結按鈕 </td>
                            <td><pre><code> \${replaceData} </code></pre></td> </tr>`)
                    })
                }

				// 顯示關鍵字查詢結果
                function drawProjectList(data) {
                    $("#projectList").empty();
                    data.forEach(function (project) {
                        $("#projectList").append(
                            `<tr><td> \${project.id} </td>)
                            <td> \${project.fullname} </td>)
                            <td>  \${project.description || ""} </td>)
                            <td><a class="btn btn-success" href="\${project.url}">連結</a></td>)
                            <td> \${project.create_datetime}</td> </tr>`)
                    })
                }

				// 將token存入localStorage
                function doCacheToken() {
                    localStorage.setItem("token", $("#token").val());
                }
				
            	// 標記欄位符合搜尋部分
                function highlightSearchText() {
                    const keyword = $('#keyword').val();
                    const regex = new RegExp(keyword , 'ig')
                    const replaceString = `<p style="background-color: rebeccapurple;">\${keyword}</p>`;
                    $(`.search-result`).each((index, element) => {
                    	const originalHTML = $(element).html();
                    	
                    	// 防止'<','>'被解析為TAG
                    	let replaceResult = originalHTML.replaceAll("<","&lt;");
                    	replaceResult = replaceResult.replaceAll(">","&gt;");
                    	
                    	// mark keyword
                    	replaceResult = replaceResult.replace(regex,replaceString);
                    	$(element).html(replaceResult);
					});
                }
                
                // 標記CODE符合搜尋部分
                function markSearchTextCode() {
                	const keyword = $('#keyword').val();
                    const regex = new RegExp(keyword , 'gi')
                    
                	$('.hljs').filter(function() {
                		// The lastIndex property specifies the index at which to start the next match.
                		regex.lastIndex = 0; // 使用g(全域)時 lastIndex會向後推，造成有時true有時false的現象
                	    return regex.test($(this).html());
                	}).each((index, element) => {
                		const originalHTML = $(element).html();
                		
                		// 使用replace，在不改變原始字串大小寫情況下加入標記
                		let replaceResult = originalHTML.replace(regex,function (str) { 
                			return'<span class="hljs-deletion">'+str+'</span>'
                		});
                		
                		$(element).html(replaceResult);
                	});
                }
                
                // 顯示專案數
                function countProjects() {
                	const findGroupString = $('#searchGroup').val();
                	
                	var totalProjects = 0;                	
                	$('#groups').children().each((index, option) => {
                		if ($(option).val().match($('#searchGroup').val())) {
	                		let projectNum = Number(option.getAttribute("project_num"));
	                		projectNum = isNaN(projectNum) ? 0 : projectNum;
	                		totalProjects += projectNum;                			
                		}
                	});
                	
                	$('#projects_count').text(totalProjects);
                }
                
            </script>
            <%@include file="common/footer.jsp" %>