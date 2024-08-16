package com.example.gitlabhelper.response.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectInfoRsDto {
	private Integer id;
	
	private String description;
	
	private String name;
	
	@JsonProperty("path_with_namespace")
	private String pathWithNamespace;
	
	@JsonProperty("created_at")
	private String createdAt;
	
	@JsonProperty("web_url")
	private String webUrl;
	
}
