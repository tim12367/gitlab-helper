package com.example.gitlabhelper.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.gitlabhelper.entity.GroupNameAndCount;
import com.example.gitlabhelper.entity.Project;

@Mapper
public interface ProjectMapper {

    void insert(Project project);

    List<Project> selectAll();

    void deleteAll();

    void insertBatch(List<Project> projects);

    List<GroupNameAndCount> selectGroupNamesAndProjectCounts();

    List<Project> selectByGroupNames(List<String> groupNames);

    List<Project> findByGroupNames(List<String> groupNames);
}
