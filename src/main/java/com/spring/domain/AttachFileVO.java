package com.spring.domain;

import lombok.Data;

@Data
public class AttachFileVO {
	private String uuid;  //uuid
	private String uploadPath;  // 2020/07/17와 같이 날짜별로 폴더명으로 저장.
	private String fileName;  // 원본파일명
	private boolean fileType; //이미지 인지 아닌지
	private int bno; //bno = 원본 글 번호
}
