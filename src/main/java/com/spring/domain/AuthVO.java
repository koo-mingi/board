package com.spring.domain;

import lombok.Data;

@Data
public class AuthVO { //spring_member_auth 테이블과 관련된 VO
	private String userid;
	private String auth;
}
