package com.spring.task;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import java.util.stream.Collector;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.spring.domain.AttachFileVO;
import com.spring.mapper.AttachMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class FileCheckTask {
	
	@Autowired
	private AttachMapper attach;

	private String getYesterDayFoler() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Calendar cal = Calendar.getInstance();
		
		cal.add(Calendar.DATE, -1);
		String str = sdf.format(cal.getTime());
		
		return str.replace("-", File.separator); // 2020/07/21 형태로 리턴
	}
	
	@Scheduled(cron="* * 2 * * *")
	public void checkFiles() {
		log.warn("파일 체크 스케줄링 실행....");
		
		//db에서 어제 날짜의 파일 목록 가져오기
		List<AttachFileVO> oldList = attach.getYesterdayFiles();
		
		//Stream : 자바 8 에서 추가됨 (컬렉션 요소를 하나씩 참조해서 람다식으로 처리하게 해줌)
		Stream<AttachFileVO> stream = oldList.stream();
		//Stream이 제공하는 map이라는 함수를 이용.파일 경로를 Stream형태로 재구성해서 filePath에 담음
		//람다식 이란? vo -> Paths.get("d:\\upload",vo.getUploadPath(),vo.getUuid()+"_"+vo.getFileName()) 이런 형태.
		Stream<Path> filePath = stream.map(vo -> Paths.get("d:\\upload",vo.getUploadPath(),vo.getUuid()+"_"+vo.getFileName()));
		
		//만들고자하는  목표 : 파일 목록들의 경로들로 이루어진 list.
		List<Path> fileListPaths= filePath.collect(Collectors.toList());
		
		//썸네일 이미지 작업하기
		//썸네일 이미지가 날아가는 것을 방지하기 위해서 fileListPahts 뒤에 다시 붙여줌
		//filter를 이용해서 이미지 파일인지 아닌지 걸러주고
		//map을 이용해서 썸네일 이미지의 경로를 만들어 준다음
		//forEach를 이용해서 fileListPaths에 붙여줌.
		oldList.stream().filter(vo -> vo.isFileType() == true)
					.map(vo -> Paths.get("d:\\upload",vo.getUploadPath(),"s_"+vo.getUuid()+"_"+vo.getFileName()))
					.forEach(p -> fileListPaths.add(p));;
					
		//어제 날짜의 폴더에 접근해서 db 파일 목록이랑 다른 내용들
		File targetDir = Paths.get("d:\\upload",getYesterDayFoler()).toFile();
		File[] removeFiles = targetDir.listFiles(file -> fileListPaths.contains(file.toPath())==false);
		
		//삭제하기
		for(File f : removeFiles) {
			log.warn("삭제파일 : "+f.getAbsolutePath());
			f.delete();
		}
	}
	
}
