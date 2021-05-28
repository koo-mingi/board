package com.spring.service;

import java.lang.annotation.Target;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.domain.AttachFileVO;
import com.spring.domain.BoardVO;
import com.spring.domain.Criteria;
import com.spring.mapper.AttachMapper;
import com.spring.mapper.BoardMapper;

@Service
public class BoardServiceImpl implements BoardService {

	@Autowired
	private BoardMapper mapper;
	@Autowired
	private AttachMapper attach;
	
	@Override
	public List<BoardVO> getList(Criteria cri) {
		return mapper.select(cri);
	}
	
	@Transactional
	@Override
	public boolean insertArticle(BoardVO vo) {
		//게시글을 DB에  저장 요청
		boolean result = mapper.insert(vo)==1?true:false;
		
		//첨부파일 DB 저장 요청 => 첨부파일에는 bno가 지정되어있지 않아서 외래키 위반으로 DB에 저장이 안됨.
		if(vo.getAttachList() == null || vo.getAttachList().size() <= 0) {
			return result;
		}
		vo.getAttachList().forEach(attach1 -> {
			attach1.setBno(vo.getBno()); // 첨부파일에 bno를 지정해줌.
			attach.insert(attach1);  // DB에 저장.
			
		});
		return result;
	}

	@Override
	public BoardVO getArticle(int bno) {
		return mapper.read(bno);
	}

	@Transactional
	@Override
	public boolean updateArticle(BoardVO vo) {
		// 현재 bno의 게시물 DB에서 삭제
		attach.delete(vo.getBno());
		// 첨부파일 삽입
		if(vo.getAttachList() != null && vo.getAttachList().size() >=0) {
			for(AttachFileVO attach1 : vo.getAttachList()) {
				attach1.setBno(vo.getBno());
				attach.insert(attach1);
			}
		}
		return mapper.update(vo)>0?true:false;
	}

	@Transactional
	@Override
	public boolean deleteArticle(int bno) {
		attach.delete(bno);
		return mapper.delete(bno)>0?true:false;
	}

	@Override
	public int totalRows(Criteria cri) {
		return mapper.total(cri);
	}

	@Override
	public List<AttachFileVO> attachList(int bno) {
		return attach.select(bno);
	}

}
