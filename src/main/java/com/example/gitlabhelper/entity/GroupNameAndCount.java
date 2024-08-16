package com.example.gitlabhelper.entity;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroupNameAndCount {

    @JsonProperty("group_name")
    private String groupName;

    private int number;

}
