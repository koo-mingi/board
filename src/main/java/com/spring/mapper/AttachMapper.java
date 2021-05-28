package com.spring.mapper;

import java.util.List;

import com.spring.domain.AttachFileVO;

public interface AttachMapper {
	public int insert(AttachFileVO vo);
	public int delete(int bno);
	public List<AttachFileVO> select(int bno);
	public List<AttachFileVO> getYesterdayFiles();
}

