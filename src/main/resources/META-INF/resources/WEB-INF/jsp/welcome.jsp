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
                    <div class="col">
                        <select class="form-select" id="searchGroup"></select>
                    </div>
                </div>
            </div>
            <!-- 查詢全部專案 -->
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
            <!-- 查詢關鍵字 -->
            <table id="keywordResultTable" class="table custom-class" style="display: none;">
                <thead>
                    <tr>
                        <th scope="col" class="col-2">群/專案</th>
                        <th scope="col" class="col-2">檔名</th>
                        <th scope="col" class="col-8">結果</th>
                    </tr>
                </thead>
                <tbody id="resultList">
                </tbody>
            </table>
            <script>

                $(document).ready(function () {
                    init();
                });

                function init() {
                    // 將localStorage的token填入input
                    $("#token").val(localStorage.getItem("token"));
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

                function initSearchGroupSelector() {
                    $.ajax({
                        url: "/gitlabhelper/groupNames",
                        type: "GET",
                        data: {
                        },
                        success: function (data) {
                            console.log(data); // debug
                            drawSearchGroupSelector(data);
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
                            highlightSearchText();
                            $("#keywordResultTable").show();
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

                function drawSearchGroupSelector(data) {
                    $("#searchGroup").empty();
                    $("#searchGroup").append(
                        `<option value="">請選擇群組</option>`)
                    data.forEach(function (groupData) {
                        $("#searchGroup").append(
                            `<option value="\${groupData.group_name}">\${groupData.group_name}\t專案筆數: \${groupData.number}</option>`)
                    })
                }

                function drawResultList(data) {
                    $("#resultList").empty();
                    
                    data.forEach((searchResult) => {
                        let infoMessage = '';
                        if (searchResult.is_over_limit) {
                            infoMessage = '<b style="color:red;">※ 超過搜尋上限，僅顯示部分資料</b><br>';
                        }

                        $("#resultList").append(
                            `<tr><td>\${infoMessage}\${searchResult.full_project_name} </td>)
                            <td class='search-result'> \${searchResult.file_name} </td>)
                            <td class='search-result'> \${searchResult.data} </td> </tr>`)
                    })
                }

                /**
                 * 將token存入localStorage
                 */
                function doCacheToken() {
                    localStorage.setItem("token", $("#token").val());
                }

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

                function highlightSearchText() {
                    const keyword = $('#keyword').val();
                    const regex = new RegExp(keyword , 'i')
                    $(`td.search-result`).each((index, data)=>
                        {data.innerHTML = 
                            data.innerHTML.replace(
                            regex,
                            `<b style="background-color: rebeccapurple;">\${keyword}</b>`
                        )}
                    )
                }
            </script>
            <%@include file="common/footer.jsp" %>