package com.spring.service;

import java.util.List;

import com.spring.domain.Criteria;
import com.spring.domain.ReplyPageVO;
import com.spring.domain.ReplyVO;

/* 변수명, 메소드명 규칙(카메레이스)
 * 소문자로 시작
 * 두 단어가 연결되었을 때 두 번째 단어의 첫 시작부분을 대문자로 줌
 * 
 * 데이터베이스 규칙(스네이크케이스)
 * reply_service / reply_insert
 * 
 * */
public interface ReplyService {
	public boolean replyInsert(ReplyVO vo);
	public ReplyVO replyRead(int rno);
	public boolean replyUpdate(ReplyVO vo);
	public boolean replyDelete(int rno);
	public ReplyPageVO replyList(Criteria cri,int bno);
}
