package com.spring.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import com.spring.domain.MemberVO;
import com.spring.mapper.MemberMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CustomUserDetailService implements UserDetailsService {

	@Autowired
	private MemberMapper mapper;
	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		log.warn("LoadUserByUsername "+username);
		
		MemberVO vo = mapper.read(username);
		
		return vo==null?null : new CustomUser(vo);
	}

}
