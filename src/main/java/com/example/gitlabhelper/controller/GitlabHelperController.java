package com.example.gitlabhelper.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.gitlabhelper.entity.GroupNameAndCount;
import com.example.gitlabhelper.entity.Project;
import com.example.gitlabhelper.response.SearchRsDto;
import com.example.gitlabhelper.service.ProjectService;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@Validated
public class GitlabHelperController {

    @Autowired
    public ProjectService projectService;

    @Schema(description = "取得所有專案")
    @GetMapping("/projects")
    public List<Project> getAllProjects(@NotBlank @RequestHeader("private-token") String privateToken) {
        return projectService.getAllProjects(privateToken);
    }

    @Schema(description = "重新取得所有專案")
    @PutMapping("/reload")
    public void reloadAllProject(@NotBlank @RequestHeader("private-token") String privateToken) {
        projectService.refreshAllProjects(privateToken);
    }

    @Schema(description = "取得所有服務群名稱及專案數量")
    @GetMapping("/groupNames")
    public List<GroupNameAndCount> getAllGroups() {
        return projectService.selectGroupNamesAndProjectCounts();
    }

    @Schema(description = "搜尋專案")
    @GetMapping("/search")
    public List<SearchRsDto> searchProjects(
            @NotBlank @RequestHeader("private-token") String privateToken,
            @RequestParam String searchGroup,
            @NotBlank @Size(min = 2) @RequestParam("keyword") String keyword) {
        return projectService.searchProjects(privateToken, searchGroup, keyword);
    }
}