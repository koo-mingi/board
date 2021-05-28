package com.spring.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.spring.domain.Criteria;
import com.spring.domain.ReplyPageVO;
import com.spring.domain.ReplyVO;
import com.spring.service.ReplyService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/replies/*")
public class ReplyController {
	
	@Autowired
	private ReplyService service;
	
	@PreAuthorize("isAuthenticated()")
	@PostMapping("/new")  //http://localhost:8080/replies/new + post
	public ResponseEntity<String> create(@RequestBody ReplyVO vo) {
		log.info("댓글 등록"+vo);
		
		return service.replyInsert(vo)? new ResponseEntity<String>("success",HttpStatus.OK)
				: new ResponseEntity<String>("fail",HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	//댓글하나 가져오기
	// http://localhost:8080/replies/3 => 끝에 rno가 오도록 할 예정
	@GetMapping("/{rno}")
	public ResponseEntity<ReplyVO> get(@PathVariable int rno) {
		log.info("댓글 가져오기 "+rno);
		ReplyVO vo = service.replyRead(rno);
		return (vo != null) ?
				new ResponseEntity<ReplyVO>(vo,HttpStatus.OK)
				: new ResponseEntity<ReplyVO>(vo,HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	//댓글하나 수정하기
	// http://localhost:8080/replies/3 + put
	@PreAuthorize("principal.username == #vo.replyer")
	@PutMapping("/{rno}")
	public ResponseEntity<String> modify(@PathVariable int rno, @RequestBody ReplyVO vo) {
		log.info("댓글 수정 : rno : "+rno+" 내용: "+vo.getReply()+" 댓글 작성자 : "+vo.getReplyer());
		
		//rno를 vo 에 담아주기
		vo.setRno(rno);
		
		return service.replyUpdate(vo)?
				new ResponseEntity<String>("success",HttpStatus.OK)
				: new ResponseEntity<String>("fail",HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	//댓글하나 삭제하기
	// http://localhost:8080/replies/3 + delete
	@PreAuthorize("principal.username == #vo.replyer")
	@DeleteMapping("/{rno}")
	public ResponseEntity<String> delete(@PathVariable int rno, @RequestBody ReplyVO vo) {
		log.info("댓글 삭제 : rno : "+rno + "댓글 작성자 "+vo.getReplyer());
		
		return service.replyDelete(rno)?
				new ResponseEntity<String>("success",HttpStatus.OK)
				: new ResponseEntity<String>("fail",HttpStatus.INTERNAL_SERVER_ERROR);
		
	}
	
	// 글번호에 해당하는 댓글 리스트 가져오기
	// http://localhost:8080/replies/pages/{bno}/{pageNum}
	// bno에 해당하는 첫버째 페이지 댓글 가져오기
	@GetMapping("/pages/{bno}/{page}")
	public ResponseEntity<ReplyPageVO> getList(@PathVariable("bno") int bno,@PathVariable("page") int page){
		log.info("댓글 가져오기 : bno : "+bno+" page : "+page);
		
		Criteria cri = new Criteria(page, 10);
		return new ResponseEntity<ReplyPageVO>(service.replyList(cri, bno),HttpStatus.OK);
	}
	
	
}
