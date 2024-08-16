package com.example.gitlabhelper.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SearchRsDto {

    @JsonProperty("project_id")
    private Integer projectId;

    @JsonProperty("full_project_name")
    private String fullProjectName;

    @JsonProperty("file_name")
    private String fileName;
    
    private String data;

    @JsonProperty("is_over_limit")
    private boolean isOverLimit;
}
