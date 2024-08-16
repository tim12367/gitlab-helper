package com.example.gitlabhelper.service;

import java.util.List;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.cloud.openfeign.SpringQueryMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.gitlabhelper.request.ProjectInfoRqDto;
import com.example.gitlabhelper.response.api.ProjectInfoRsDto;
import com.example.gitlabhelper.response.api.SearchBlobRsDto;

import jakarta.validation.Valid;

@FeignClient(name = "gitlab-api", url = "${gitlab.api.url}")
public interface GitLabApiService {

	// 獲得project資訊
	@GetMapping("/projects")
	List<ProjectInfoRsDto> getProjects(
			@Valid @SpringQueryMap ProjectInfoRqDto request,
			@RequestHeader("PRIVATE-TOKEN") String privateToken);

	@GetMapping("/projects/{id}/search?scope=blobs")
	List<SearchBlobRsDto> searchProjects(
			@RequestHeader("PRIVATE-TOKEN") String privateToken,
			@PathVariable Integer id,
			@RequestParam("search") String keyword);
}
