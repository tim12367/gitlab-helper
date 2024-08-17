package com.example.gitlabhelper.service;

import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;

import com.example.gitlabhelper.entity.GroupNameAndCount;
import com.example.gitlabhelper.entity.Project;
import com.example.gitlabhelper.mapper.ProjectMapper;
import com.example.gitlabhelper.request.ProjectInfoRqDto;
import com.example.gitlabhelper.response.SearchRsDto;
import com.example.gitlabhelper.response.api.ProjectInfoRsDto;
import com.example.gitlabhelper.response.api.SearchBlobRsDto;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ProjectService {

    @Autowired
    private ProjectMapper projectMapper;

    @Autowired
    private GitLabApiService gitLabApiService;

    @Autowired
    private Environment environment;
    
    public List<Project> getAllProjects(String privateToken) {
        List<Project> projects = this.selectAll();

        // 如果資料庫沒有資料就重新取得
        if (projects.isEmpty()) {
            this.refreshAllProjects(privateToken);
            projects = this.selectAll();
        }

        return projects;
    }

    /**
     * 批次新增 ProjectInfoRsDto
     * 
     * @param projectInfos
     */
    public void insertBatchProjectInfo(List<ProjectInfoRsDto> projectInfos) {
        List<Project> projects = new ArrayList<>();

        // 將 ProjectInfoRsDto 轉換成 Project
        projectInfos.stream().forEach(projectInfo -> {
            ZonedDateTime zonedDateTime = ZonedDateTime.parse(projectInfo.getCreatedAt());
            LocalDateTime createDate = zonedDateTime.toLocalDateTime();
            String groupName = projectInfo.getPathWithNamespace().split("/")[0];
            String projectName = projectInfo.getPathWithNamespace().split("/")[1];

            Project project = Project.builder()
                    .id(projectInfo.getId())
                    .description(projectInfo.getDescription())
                    .fullname(projectInfo.getPathWithNamespace())
                    .groupName(groupName)
                    .projectName(projectName)
                    .createDatetime(createDate)
                    .url(projectInfo.getWebUrl())
                    .build();
            projects.add(project);
        });

        this.insertBatch(projects);
    }

    /**
     * 批次新增
     * 
     * @param projects
     */
    public void insertBatch(List<Project> projects) {
        int index = 1;
        List<Project> tempList = new ArrayList<>();

        for (Project project : projects) {

            tempList.add(project);

            if (index % 100 == 0 || index == projects.size()) {
                projectMapper.insertBatch(tempList);
                tempList = new ArrayList<>();
            }

            index++;
        }

    }

    public void refreshAllProjects(String privateToken) {
        this.deleteAll();

        List<ProjectInfoRsDto> projectInfos = this.getAllProjectsFromApi(privateToken);
        log.debug("查詢總筆數: " + projectInfos.size());

        this.insertBatchProjectInfo(projectInfos);
    }

    public List<SearchRsDto> searchProjects(String privateToken, String searchGroup, String keyword) {
        List<Project> projects = this.selectByGroupNames(Arrays.asList(searchGroup));

        if (projects.isEmpty()) {
            projects = this.getAllProjects(privateToken);
        }

        List<SearchRsDto> searchRsDtos = new ArrayList<>();

        for (Project project : projects) {
            List<SearchBlobRsDto> apiResponse = gitLabApiService.searchProjects(privateToken, project.getId(), keyword);

            boolean isOverLimit = false;

            if (apiResponse.size() >= 20) {
                log.debug("超過20個結果" + apiResponse.size() + "筆資料");
                isOverLimit = true;
            }

            // 將api回傳的資料轉換成SearchRsDto
            for (SearchBlobRsDto result : apiResponse) {
                SearchRsDto searchRsDto = SearchRsDto.builder()
                        .projectId(result.getProjectId())
                        .fullProjectName(project.getFullname())
                        .fileName(result.getFilename())
                        .data(result.getData())
                        .isOverLimit(isOverLimit)
                        .build();
                searchRsDtos.add(searchRsDto);
            }
        }


        return searchRsDtos;
    }

    // call gitlab api 取得專案
	public List<ProjectInfoRsDto> getAllProjectsFromApi(String privateToken) {

		// 限制最大筆數 -1為無限制
		Integer limit = environment.getProperty("api.allprojects.limit", Integer.class, -1);

		List<ProjectInfoRsDto> result = new ArrayList<>();
		int index = 1;

		while (true) { // 一次取100筆 一直取到沒有資料
			
			// 超過最大筆數就跳出 -1 不限制
			if (limit != -1 && result.size() >= limit) {
				break;
			}

			// call api(一次幾個project, 第幾批資料)
			List<ProjectInfoRsDto> apiResponse = this.getProjectsByPageAndPerPage(100, index, privateToken);

			// 如果沒有資料就跳出
			if (apiResponse.isEmpty()) {
				break;
			}

			result.addAll(apiResponse);

			index++;
		}

		return result;
	}

    private List<ProjectInfoRsDto> getProjectsByPageAndPerPage(int perPage, int page, String privateToken) {
        ProjectInfoRqDto apiRequest = ProjectInfoRqDto.builder()
                .per_page(perPage)
                .page(page)
                .build();

        // 使用log印出request response
        return gitLabApiService.getProjects(apiRequest, privateToken);
    }

    public List<Project> selectAll() {
        return projectMapper.selectAll();
    }

    public void insert(Project entity) {
        projectMapper.insert(entity);
    }

    public void deleteAll() {
        projectMapper.deleteAll();
    }

    public List<GroupNameAndCount> selectGroupNamesAndProjectCounts() {
        return projectMapper.selectGroupNamesAndProjectCounts();
    }

    public List<Project> selectByGroupNames(List<String> groupNames) {
        return projectMapper.selectByGroupNames(groupNames);
    }

    public List<Project> findByGroupNames(List<String> groupNames) {
        return projectMapper.findByGroupNames(groupNames);
    }

}
