package com.spring.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.domain.Criteria;
import com.spring.domain.ReplyPageVO;
import com.spring.domain.ReplyVO;
import com.spring.mapper.BoardMapper;
import com.spring.mapper.ReplyMapper;

@Service
public class ReplyServiceImpl implements ReplyService {

	@Autowired
	private ReplyMapper mapper;
	@Autowired
	private BoardMapper board;
	
	@Transactional
	@Override
	public boolean replyInsert(ReplyVO vo) {
		//댓글 게시물 수 변경
		board.updateReplyCnt(vo.getBno(), 1);
		return mapper.insert(vo)==1?true:false;
	}

	@Override
	public ReplyVO replyRead(int rno) {
		return mapper.read(rno);
	}

	@Override
	public boolean replyUpdate(ReplyVO vo) {
		return mapper.update(vo)==1?true:false;
	}

	@Transactional
	@Override
	public boolean replyDelete(int rno) {
		//rno를 이용해서 bno 알아내기
		ReplyVO vo = mapper.read(rno);
		
		//댓글 게시물 수 변경
		board.updateReplyCnt(vo.getBno(), -1); // 삭제 실패 시 rollback해줘야 함
		return mapper.delete(rno)==1?true:false;
	}

	@Override
	public ReplyPageVO replyList(Criteria cri, int bno) {	
		return new ReplyPageVO(mapper.getCountByBno(bno),mapper.list(cri, bno));
	}

}
