package com.spring.domain;

import lombok.Data;

@Data
public class PageVO {
	private int startPage;
	private int endPage;
	private boolean prev;
	private boolean next;
	private int total;
	private Criteria cri;
	
	public PageVO(Criteria cri,int total) {
		this.cri = cri;
		this.total = total;
		
		//끝나는 페이지 계산
		endPage = (int)(Math.ceil(cri.getPageNum()/10.0))*10;
		//시작 페이지 계산
		startPage = this.endPage - 9;
		
		//끝나는 페이지가 10개가 안될 수도 있기 때문에
		//실제로 끝나는 페이지 구하기
		int realEnd = (int)(Math.ceil((total/1.0) / cri.getAmount()));
		if(realEnd < this.endPage) {
			endPage = realEnd;
		}
		this.prev = startPage > 1;
		this.next = endPage < realEnd;
	}
}

