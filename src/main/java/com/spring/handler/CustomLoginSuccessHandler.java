package com.spring.handler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.jaas.AuthorityGranter;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CustomLoginSuccessHandler implements AuthenticationSuccessHandler {

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
			Authentication authentication) throws IOException, ServletException {
		log.info("Loging Success Handler");
		
		//Authentication 정보확인하기
		List<String> roleNames = new ArrayList<String>();
		authentication.getAuthorities().forEach(authority -> roleNames.add(authority.getAuthority()));
		
		log.info("roleNames : "+roleNames);
		
		//부여된 권한에 따라서 페이지 이동시키기
		if(roleNames.contains("ROLE_ADMIN")) {
			response.sendRedirect("/member/admin");
			return;  // 핸들러이니까 그냥 주소 가지고 돌아가라는 뜻.
		}else if(roleNames.contains("ROLE_MEMBER") || roleNames.contains("ROLE_MANAGER")) {
			response.sendRedirect("/board/list");
			return;
		}
		response.sendRedirect("/"); //일반 사용자는 여기서 걸림
	}
}
