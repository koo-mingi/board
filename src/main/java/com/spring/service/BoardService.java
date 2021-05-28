package com.spring.service;

import java.util.List;

import com.spring.domain.AttachFileVO;
import com.spring.domain.BoardVO;
import com.spring.domain.Criteria;

public interface BoardService {
	//게시물 기능
	public List<BoardVO> getList(Criteria cri);
	public boolean insertArticle(BoardVO vo);
	public BoardVO getArticle(int bno);
	public boolean updateArticle(BoardVO vo);
	public boolean deleteArticle(int bno);
	int totalRows(Criteria cri);  // public을 안써주면 기본적으로 public
	
	//첨부물 기능
	List<AttachFileVO> attachList(int bno);
}
