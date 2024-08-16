package com.example.gitlabhelper.request;

import com.fasterxml.jackson.annotation.JsonInclude;

import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL) // null不轉換
public class ProjectInfoRqDto {

	@Min(1)
	private Integer per_page;

	@Min(1)
	private Integer page;
}
