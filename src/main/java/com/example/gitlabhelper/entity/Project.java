package com.example.gitlabhelper.entity;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Project {

    private Integer id;

    private String fullname;

    @JsonProperty("group_name")
    private String groupName;

    @JsonProperty("project_name")
    private String projectName;

    private String description;

    private String url;

    @JsonProperty("create_datetime")
    private LocalDateTime createDatetime;
}
