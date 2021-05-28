create table spring_board(
	bno number(10,0),
	title varchar2(200) not null,
	content varchar2(2000) not null,
	writer varchar2(50) not null,
	regdate date default sysdate,
	updatedate date default sysdate
);

alter table spring_board add constraint pk_spring_board primary key(bno);

create sequence seq_board;

select * from SPRING_BOARD;

-- 댓글 수 컬럼 추가
alter table spring_board add(replycnt number default 0);

-- 기존 댓글 수 업데이트
update spring_board set replycnt = (select count(*) from spring_reply where spring_reply.bno = spring_board.bno);

