package com.example.gitlabhelper;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class GitlabhelperApplication {

	public static void main(String[] args) {
		SpringApplication.run(GitlabhelperApplication.class, args);
	}

}
