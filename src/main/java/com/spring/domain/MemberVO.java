package com.spring.domain;

import java.util.Date;
import java.util.List;

import lombok.Data;

@Data
public class MemberVO {
	private String userid;
	private String userpw;
	private String username;
	private Date regdate;
	private Date updatedate;
	private boolean enabled;
	
	//권한정보
	//리스트로 해준이유 : 하나의 계정에 여러 권한이 들어올 수가 있기 때문에.
	private List<AuthVO> authList; 
}
