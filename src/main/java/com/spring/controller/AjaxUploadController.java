package com.spring.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.spring.domain.AttachFileVO;

import lombok.extern.slf4j.Slf4j;
import net.coobird.thumbnailator.Thumbnailator;

@Controller
@Slf4j
public class AjaxUploadController {
	
	@GetMapping("/uploadAjax")
	public void uploadAjaxGet() {
		log.info("uploadAjax 페이지 요청");
	}
	
	@PreAuthorize("isAuthenticated()")
	@PostMapping(value="/uploadAjax",produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public ResponseEntity<List<AttachFileVO>> uploadAjaxPost(MultipartFile[] uploadFile) {
		log.info("upload Ajax 요청");
		String uploadFolder = "d:\\upload";
		String uploadFileName = "";
		
		String uploadFolderPath = getFolder(); // 2020\07\17 형태로 뜸.
		log.info("uploadFolderPath : "+uploadFolderPath);
		File uploadPath	= new File(uploadFolder,uploadFolderPath);
		
		if(!uploadPath.exists()) {
			uploadPath.mkdirs();  // 년/월/일 값으로 폴더 생성
		}
		
		List<AttachFileVO> attachList = new ArrayList<AttachFileVO>();
		for(MultipartFile f:uploadFile) {
			log.info("-------------------");
			log.info("upload File Name : "+f.getOriginalFilename());
			log.info("upload File Size : "+f.getSize());
			
			//파일의 중복을 제거하기 위해 고유값 설정
			UUID uuid = UUID.randomUUID();
			uploadFileName =uuid.toString()+"_"+f.getOriginalFilename();
						
			AttachFileVO attach = new AttachFileVO();
			attach.setFileName(f.getOriginalFilename());
			attach.setUploadPath(uploadFolderPath);
			attach.setUuid(uuid.toString());
			
			try {
				Path saveFile = Paths.get(uploadPath.getPath(), uploadFileName);
				
				//이미지 여부 확인
				if(checkImageType(saveFile.toFile())) {
					attach.setFileType(true);
					
					//썸네일 작업
					FileOutputStream thumbnail = new FileOutputStream(new File(uploadPath, "s_"+uploadFileName));
					Thumbnailator.createThumbnail(f.getInputStream(),thumbnail,100,100);
					thumbnail.close();
				}
				
				f.transferTo(saveFile); // 서버 폴더에 파일을 저장.
				attachList.add(attach);
			} catch (IllegalStateException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		// OK 상태코드와 uuid가 붙은 파일명 리턴
		return new ResponseEntity<List<AttachFileVO>>(attachList,HttpStatus.OK);
	}
	
	//썸네일 이미지를 리턴하는 컨트롤러
	@GetMapping("/display")
	@ResponseBody
	public ResponseEntity<byte[]> getFile(String fileName){
		log.info("썸네일 요청  "+fileName);
		File f = new File("d:\\upload\\"+fileName);
		
		ResponseEntity<byte[]> result = null;
		
		HttpHeaders headers = new HttpHeaders();
		
		try {
			headers.add("Content-Type", Files.probeContentType(f.toPath()));
			result = new ResponseEntity<byte[]>(FileCopyUtils.copyToByteArray(f),headers,HttpStatus.OK);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	
	//이미지 여부 확인
	private boolean checkImageType(File file) {
		String contentType;
		try {
			contentType = Files.probeContentType(file.toPath());
			return contentType.startsWith("image");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}
	
	//날짜별 폴더 생성
	private String getFolder() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		
		Date date = new Date();
		String str = sdf.format(date);
		return str.replace("-", File.separator);
	}
	
	@PreAuthorize("isAuthenticated()")
	@PostMapping("/deleteFile")
	@ResponseBody
	public ResponseEntity<String> deleteFile(String fileName, String type){
		log.info("첨부파일 삭제 : fileName = "+fileName+", type = "+type);
		
		try {
			File file = new File("d:\\upload\\"+URLDecoder.decode(fileName,"utf-8"));
			
			//썸네일 혹은 일반 파일 삭제
			file.delete();
			if(type.equals("image")) {
				String oriPath = file.getAbsolutePath().replace("s_", "");
				file = new File(oriPath);
				
				//이미지 원본 파일 삭제
				file.delete();
			}
			
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return new ResponseEntity<String>("deleted",HttpStatus.OK);
	}
	
	//다운로드 컨트롤러
		@GetMapping(value="/download",produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
		@ResponseBody
		public ResponseEntity<Resource> downloaFile(String fileName) {
			log.info("다운로드 파일 : "+fileName);
			
			Resource resource = new FileSystemResource("d:\\upload\\"+fileName);
			
			String resourceName = resource.getFilename();
			
			//브라우저 헤더에 붙여 보내기
			HttpHeaders headers = new HttpHeaders();
			try {
//				uuid값이 붙어서 다운로드가 되는 상황
//				headers.add("Content-Disposition", "attachment;fileName="
//						+new String(resourceName.getBytes("utf-8"),"ISO-8859-1"));
				
				//uuid 값 제거
				String resourceUidName = resource.getFilename();
				resourceName = resourceUidName.substring(resourceUidName.indexOf("_")+1);
				headers.add("Content-Disposition", "attachment;fileName="
						+new String(resourceName.getBytes("utf-8"),"ISO-8859-1"));
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return new ResponseEntity<Resource>(resource,headers,HttpStatus.OK);
		}
	
}
