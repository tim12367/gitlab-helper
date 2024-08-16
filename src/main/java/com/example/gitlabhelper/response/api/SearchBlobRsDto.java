package com.example.gitlabhelper.response.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class SearchBlobRsDto {
    private String basename;

    private String data;

    private String path;

    private String filename;

    private String id;

    private String ref;

    private int startline;
    
    @JsonProperty("project_id")
    private int projectId;
}
