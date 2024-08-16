package com.example.gitlabhelper.request;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class ProjectsRsDto {
	@JsonProperty("PRIVATE-TOKEN")
	private String privateToken;
}
