create table spring_reply(
	rno number(10) constraint pk_reply primary key, -- 댓글 글번호
	bno number(10) not null, -- 원본 글 번호
	reply varchar2(1000) not null, -- 댓글 내용
	replyer varchar2(50) not null, -- 댓글 작성자
	replydate date default sysdate, -- 댓글 작성일
	updatedate date default sysdate, -- 댓글 수정일
	constraint fk_spring_reply foreign key(bno) references spring_board(bno) -- 외래키
);

create sequence seq_reply;

select * from spring_reply;


