package com.spring.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.domain.AttachFileVO;
import com.spring.domain.BoardVO;
import com.spring.domain.Criteria;
import com.spring.domain.PageVO;
import com.spring.service.BoardService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/board")
public class BoardController {
	
	@Autowired
	private BoardService service;
	
	@PreAuthorize("isAuthenticated()")  // 인증된 사용자인 경우 true
	@GetMapping("/register")
	public void registerGet() {
		log.info("register 페이지 요청");
	}
	
	@PreAuthorize("isAuthenticated()")
	@PostMapping("/register")
	public String registerPost(BoardVO vo,RedirectAttributes rttr) {
		log.info("새글 작성");
		
		if(vo.getAttachList()!=null) {
			vo.getAttachList().forEach(attach -> log.info(attach+""));
		}
		try {
			if(service.insertArticle(vo)) {
				rttr.addFlashAttribute("result", vo.getBno());
				return "redirect:/board/list";
			}else {
				return "redirect:/board/register";
			}
		} catch (Exception e) {
			return "redirect:/board/register";
		}
		//return "redirect:/board/list";
	}
	
	@GetMapping("/list")
	public String listGet(Model model,@ModelAttribute("cri") Criteria cri) {
		log.info("list 페이지 요청");
		List<BoardVO> list =  service.getList(cri);
		
		//하단의 페이지나누기와 관련된 정보
		model.addAttribute("pageVO", new PageVO(cri, service.totalRows(cri))); // total은 sql문을 이용해서 가져온다.
		
		if(!list.isEmpty()) {
			model.addAttribute("list", list);
			return "/board/list";
		}else {
			return "redirect:/";
		}
	}
	
	@GetMapping(value= {"/read","/modify"})
	public String readGet(int bno,@ModelAttribute("cri") Criteria cri,Model model,HttpServletRequest request) {
		log.info("내용보기 페이지 요청..");
		log.info("bno = "+bno+" ,cri : "+cri);
		
		String URI = request.getRequestURI();
		int index = URI.lastIndexOf("/");
		String cmd = URI.substring(index);
		log.info("URI : "+URI);
		log.info("/의 마지막 위치 : "+index);
		log.info("cmd : "+cmd);
		
		BoardVO board = service.getArticle(bno);
		if(board!=null) {
			model.addAttribute("board", board);
			return URI; // read 또는 modify로 이동.
		}else {
			return "redirect:/board/list";
		}
	}
//	
//	@GetMapping("/modify")
//	public String modifyGet(int bno,Model model) {
//		log.info("modify 페이지 요청");
//		log.info("bno = "+bno);
//		
//		BoardVO board = service.getArticle(bno);
//		if(board!=null) {
//			model.addAttribute("board", board);
//			return "/board/modify";
//		}else {
//			return "redirect:/board/modify?bno="+bno;
//		}
//	}
	
	@PreAuthorize("principal.username == #vo.writer")
	@PostMapping("/modify")
	public String modifyPost(BoardVO vo,Criteria cri, RedirectAttributes rttr) {
		log.info("수정 요청");
		log.info("cri : "+cri);
		
		
		try {
			if(service.updateArticle(vo)) {
				log.info("수정 성공");
				rttr.addAttribute("bno", vo.getBno());
				rttr.addAttribute("pageNum", cri.getPageNum());
				rttr.addAttribute("amount", cri.getAmount());
				rttr.addAttribute("type", cri.getType());
				rttr.addAttribute("keyword", cri.getKeyword());
				//rttr.addFlashAttribute("bno", vo.getBno());
				//return "redirect:/board/read?bno="+vo.getBno();
				return "redirect:/board/read";
			}else {
				log.info("수정 실패");
				rttr.addAttribute("bno", vo.getBno());
				rttr.addAttribute("pageNum", cri.getPageNum());
				rttr.addAttribute("amount", cri.getAmount());
				rttr.addAttribute("type", cri.getType());
				rttr.addAttribute("keyword", cri.getKeyword());
				//return "redirect:/board/modify?bno="+vo.getBno();
				return "redirect:/board/modify";
			}
			
		} catch (Exception e) {
			log.info("수정 실패");
			rttr.addAttribute("bno", vo.getBno());
			//return "redirect:/board/modify?bno="+vo.getBno();
			return "redirect:/board/modify";
		}
	}
	
	@PreAuthorize("principal.username == writer")
	@PostMapping("/remove")
	public String remove(int bno, String writer,Criteria cri,RedirectAttributes rttr) {
		log.info("삭제 요청");
		
		// 현재 글번호에 해당하는 첨부파일 목록을 서버에서 삭제하기 위해서
		// bno에 해당하는 첨부파일 리스트 가져오기
		List<AttachFileVO> attachList = service.attachList(bno);
		
		if(service.deleteArticle(bno)) {
			log.info("삭제 성공");
			rttr.addAttribute("pageNum", cri.getPageNum());
			rttr.addAttribute("amount", cri.getAmount());
			rttr.addAttribute("type", cri.getType());
			rttr.addAttribute("keyword", cri.getKeyword());
			rttr.addFlashAttribute("result", "success");
			deleteFiles(attachList); // 서버 폴더의 첨부파일 삭제
			return "redirect:/board/list";
		}else {
			log.info("삭제 실패");
			rttr.addAttribute("bno", bno);
			return "redirect:/board/modify";
		}
	}
	
	//첨부물 가져오기 컨트롤러 작성
	@GetMapping("/getAttachList")
	public ResponseEntity<List<AttachFileVO>> getAttachList(int bno){
		log.info("첨부물 가져오기 "+bno);
		return new ResponseEntity<List<AttachFileVO>>(service.attachList(bno),HttpStatus.OK);
	}
	
	//게시물 삭제 시 서버 폴더에 첨부물 삭제
	private void deleteFiles(List<AttachFileVO> attachList) {
		if(attachList == null || attachList.size() == 0) {
			return;
		}
			
		for(AttachFileVO vo : attachList) {
			Path file = Paths.get("d:\\upload\\",vo.getUploadPath()+"\\"+vo.getUuid()+"_"+vo.getFileName());
			
			try {
				//일반파일, 이미지 원본 파일 삭제
				Files.deleteIfExists(file);
				
				//썸네일 삭제
				if(Files.probeContentType(file).startsWith("image")) {
					Path thumb = Paths.get("d:\\upload\\",vo.getUploadPath()+"\\"+vo.getUuid()+"_"+vo.getFileName());
					Files.delete(thumb);					
				}
				
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}


