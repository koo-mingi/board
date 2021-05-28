<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/mycss.css" />
<%@include file="../includes/header.jsp" %>
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Board Read</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>            
            <div class="row">
                <div class="col-lg-12">
                	<div class="panel panel-default">
                        <div class="panel-heading">
                           Board Read Page
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                			<form role="form">
                				<div class="form-group">
                					<label>Bno</label>
                					<input class="form-control" name="bno" value="<%=request.getParameter("bno") %>" readonly="readonly">                				
                				</div> 
                				<div class="form-group">
                					<label>Title</label>
                					<input class="form-control" name="title" value = "${board.title}" readonly="readonly">                				
                				</div>  
                				<div class="form-group">
                					<label>Content</label>
                					<textarea class="form-control" rows="3" name="content" readonly="readonly">${board.content}</textarea>               				
                				</div> 
                				<div class="form-group">
                					<label>Writer</label>
                					<input class="form-control" name="writer" value = "${board.writer}" readonly="readonly">                				
                				</div>
                				<sec:authentication property="principal" var="info"/>
                				<sec:authorize access="isAuthenticated()">
                					<c:if test="${info.username == board.writer}">
		                				<button type="button" class="btn btn-default" <%-- onclick="location.href='modify?bno=${board.bno}'" --%>>Modify</button>                 					
                					</c:if>
                				</sec:authorize>  
                				<button type="reset" class="btn btn-info" <%-- onclick="location.href='list'" --%>>List</button>          			
                			</form>
                		</div>
                	</div>
                </div>
            </div>
<!-- 첨부 파일 영역 -->
<div class="bigPictureWrapper">
	<div class="bigPicture"></div>
</div>
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading"><i class="fa fa-comments fa-fw">Files</i>
			<div class="panel-body">
				<div class="uploadResult">
					<ul></ul>				
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 댓글 영역 -->
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-comments fa-fw"></i>
				Reply
				<sec:authorize access="isAuthenticated()">
					<button id="addReplyBtn" class="btn btn-primary btn-xs pull-right">
						New Reply
					</button>
				</sec:authorize>
			</div>
			<div class="panel-body">
				<ul class="chat">
					<li class="left clearfix" data-rno='30'>
						<div>
							<div class="header">
								<strong class="primary-font">댓글러00</strong>
								<small class="pull-right text-muted">
									2020.07.15 12:14
								</small>
							</div>
							<p>Good Job!!!</p>
						</div>
					</li>
				</ul>
			</div>
			<div class="panel-footer"><!-- 댓글 페이지 영역 -->
				
			</div>
		</div>
	</div>
</div>
<!-- 댓글 등록 모달 -->
<div class="modal" tabindex="-1" role="dialog" id="replyModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        <h5 class="modal-title">Modal title</h5>
      </div>
      <div class="modal-body">
       <div class="form-group">
       	<label for="">댓글 내용</label>
       	<input type="text" class="form-control" name="reply" value="댓글내용" />
       </div>
       <div class="form-group">
       	<label for="">작성자</label>
       	<input type="text" class="form-control" name="replyer" value="작성자" />
       </div>
       <div class="form-group">
       	<label for="">작성일</label>
       	<input type="text" class="form-control" name="replyDate" value="작성일" />
       </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-warning" id="modalRegisterBtn">등록</button>
        <button type="button" class="btn btn-success" id="modalModifyBtn">수정</button>
        <button type="button" class="btn btn-danger" id="modalRemoveBtn">삭제</button>
        <button type="button" class="btn btn-primary" id="modalCloseBtn" data-dismiss="modal">닫기</button>
      </div>
    </div>
  </div>
</div>            
<%--페이지 나누기와 다른 작업들을 위해서 폼 작성 --%>
<form action="" id="myForm">
	<input type="hidden" name="bno" value="${board.bno}" />
	<input type="hidden" name="pageNum" value="${cri.pageNum}" />
	<input type="hidden" name="amount" value="${cri.amount}" />
	<input type="hidden" name="type" value="${cri.type}" />
	<input type="hidden" name="keyword" value="${cri.keyword}" />
</form>
<script>
	$(function(){
		let form = $("#myForm");
		$(".btn-default").click(function(){
			form.attr('action','modify'); //http://~~/board/modify
			form.submit();
		})
		$(".btn-info").click(function(){
			form.attr('action','list');
			//bno 는 삭제하기
			form.find("input[name='bno']").remove();
			form.submit();
		})
	})
</script>           
<script src="/resources/js/reply.js"></script>
<script>
function showImage(fileCallPath){
	$(".bigPictureWrapper").css("display","flex").show();
	
	$(".bigPicture").html("<img src='/display?fileName="+fileCallPath+"'>")
					.animate({width:'100%',height:'100%'},1000);
}
$(function(){
	
	//현재 글의 글 번호 가져오기
	let bno = ${board.bno};
	
	//------------------------------------- 첨부파일 스크립트 시작
	
	// bno를 보내서 해당 게시물의 첨부파일 내역 가져오기 => ajax
	// http://~~~~/board/getAttachList
	$.getJSON("getAttachList",{bno:bno},function(data){
		console.log(data); //json 형태로 데이터 도착 확인
		
		let str = "";
		let uploadResult = $(".uploadResult ul");
		$(data).each(function(i,element){
			if(element.fileType){ //이미지
				var fileCallpath = encodeURIComponent(element.uploadPath+"\\s_"+element.uuid+"_"+element.fileName);
			
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<div><span><a>"+element.fileName+"</span></div>";
				str += "<img src='/display?fileName="+fileCallpath +"'></a></li>";
			}else{ //일반파일
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<div><span><a>"+element.fileName+"</span></div>";
				str += "<img src='/resources/img/attach.png'></a></li>";
			}
		})
		
		uploadResult.html(str);
	})// 첨부파일 내역 종료
	
	// li는 마지막에 생기는 영역이라, on을 이용해서 li가 생기면 위임하라는 뜻.
	$(".uploadResult").on("click","li",function(){ 
		//이미지 파일은 크게 보여주고, 일반 파일은 다운로드 창 띄우기
		
		//클릭된 객체 가져오기
		let liObj = $(this);
		console.log(liObj);
		
		//인코딩
		var fileCallPath = encodeURIComponent(liObj.data("path")+"\\"+liObj.data("uuid")+"_"+liObj.data("filename"));
		console.log(fileCallPath);
		if(liObj.data("type")){
			showImage(fileCallPath.replace(new RegExp(/\\/g), "/"));
		}else{
			location.href="/download?fileName="+fileCallPath;
		}
		
	})// 첨부파일 처리 종료
	
	//확대 사진 닫기
	$(".bigPictureWrapper").on("click",function(){
		$(".bigPicture").animate({width:'0%',height:'0%'},1000); // 1000 : 1/1000초. 애니메이션이 이루어지는 시간.
		setTimeout(function(){
			$(".bigPictureWrapper").hide();
		},1000);
	})
	
	//------------------------------------- 첨부파일 스크립트 종료
	
	//댓글 영역 가져오기
	let replyUl = $(".chat");
	
	//댓글 영역 내용을 보여주는 함수 호출
	showList(1);
	
	//모달 영역 가져오기
	let modal = $(".modal");
	//모달 영역이 가지고 있는 input 영역 찾기
	let modalInputReply = modal.find("input[name='reply']");
	let modalInputReplyer = modal.find("input[name='replyer']");
	let modalInputReplyDate = modal.find("input[name='replyDate']");
	//모달 영역이 가지고 있는 버튼 찾기
	let modalModifyBtn = $("#modalModifyBtn");
	let modalRemoveBtn = $("#modalRemoveBtn");
	let modalRegisterBtn = $("#modalRegisterBtn");
	
	//csrf 토큰 값 생성
	let csrfHeaderName = "${_csrf.headerName}";
	let csrfTokenValue = "${_csrf.token}";
	
	//ajax가 호출될 때는 무조건 이 부분이 따라가도록 설정
	$(document).ajaxSend(function (e,xhr,options) {
		xhr.setRequestHeader(csrfHeaderName, csrfTokenValue);	
	})
	
	//현재 로그인 사용자 값 가져오기
	let replyer = null;
	<sec:authorize access="isAuthenticated()">
	replyer = '<sec:authentication property="principal.username"/>';
	</sec:authorize>
	
	$("#addReplyBtn").click(function(){
		//input 안에 들어있는 내용 없애주기
		modal.find("input").val("");
		
		//현재 로그인한 사용자 repler에 보여주기
		modalInputReplyer.val(replyer).attr("readonly","readonly");
		
		//작성날짜 영역 없애기
		modalInputReplyDate.closest("div").hide();
		
		//닫기 버튼만 제외하고 모든 버튼을 숨기기
		modal.find("button[id!='modalCloseBtn']").hide();
		
		//등록 버튼 다시 보이기
		modalRegisterBtn.show();
		
		modal.modal("show");
	})
	
	//댓글 작업 호출
	//댓글 등록 하기
	// on("click",~~~~) : click 과 같은 역할인데, 동적 바인딩 기능이 추가됨
	//					    여러 이벤트를 동시에 추가할 수가 있음
	
	//댓글 페이지 나누기로 추가
	let pageNum = 1;
	
	modalRegisterBtn.on("click",function(){
		var reply = {
				bno:bno,
				replyer:modalInputReplyer.val(),
				reply:modalInputReply.val()
		};
		replyService.add(reply,
			function(result){
				alert(result);
				//modal 에 있는 댓글 내용과 관련된 내용 지우기
				modal.find("input").val();
				//모달 창 종료
				modal.modal("hide");
				//전체 댓글 리스트 보기
				//-1로 변경해서 맨 마지막 페이지를 보여주기
				showList(-1);
		});//add 종료 
	})
	
	//댓글 리스트 요청하기
	function showList(page){
	 	replyService.getList({bno:bno,page:page},function(total,list){
			//alert(result);
			console.log(list);
			
			if(page == -1){
				pageNum = Math.ceil(total/10.0);
				showList(pageNum);
				return;
			}
			
			if(list === null || list.length === 0){
				replyUl.html("");
				return;
			}
			
			let str = "";
			for(var i = 0,len = list.length||0;i<len;i++){
				str += "<li class='left clearfix' data-rno='"+list[i].rno+"'>";
				str += "<div><div class=\"header\">";
				str += "<strong class='primary-font'>"+list[i].replyer+"</strong>";
				str += "<small class='pull-right text-muted'>"+replyService.displayTime(list[i].replydate)+"</small>";
				str += "</div><p>"+list[i].reply+"</p></div></li>";
			}
			
			replyUl.html(str);
			showReplyPage(total);
			
		})//getList 종료 		
	}
	//댓글 페이지 영역 가져오기
	let replyPageFooter = $(".panel-footer");
	function showReplyPage(total){
		
		//마지막 페이지 계산
		let endPage = Math.ceil(pageNum/10.0)*10;
		//시작 페이지 계산
		let startPage = endPage -9;
		//이전버튼
		let prev = startPage != 1;
		//다음 버튼
		let next = false;
		
		//실제 마지막 페이지 계산
		if(endPage * 10 >= total){
			endPage = Math.ceil(total/10.0);
		}
		if(endPage * 10 < total){
			next = true;
		}
		//디자인 작성 후 댓글 페이지 영역에 보여주기
		let str = "<ul class='pagination pull-right'>";
		if(prev){
			str += "<li class='page-item'><a class='page-link'";
			str += " href='"+(startPage - 1)+"'>Prev</a></li>";
		}
		for(var i=startPage; i<= endPage;i++){
			let active = pageNum == i ? "active":""; // pageNum = "2", i = 2 => ===으로 타입까지 비교하면 다르다고 뜸
			str += "<li class='page-item "+active+"'>";
			str += "<a class='page-link' href='"+i+"'>"+i;
			str += "</a></li>";
		}
		if(next){
			str += "<li class='page-item'><a class='page-link'";
			str += " href='"+(endPage + 1)+"'>Next</a></li>";
		}
		str += "</ul></div>";
		replyPageFooter.html(str);
		
	}
	
	//댓글 페이지 번호를 누르면 실행되는 스크립트
	replyPageFooter.on("click","li a",function(e){
		//a 때문에 움직이는 이벤트 제거
		e.preventDefault();
		
		pageNum = $(this).attr("href");
		showList(pageNum);
	})
	
	
	//댓글 삭제
	// $("#modalRemoveBtn").click(function(){})
	$(modalRemoveBtn).on("click",function(){ // 삭제버튼을 클릭하면
		
		//댓글 삭제 버튼이 눌러지면 로그인 여부 확인하기
		if(!replyer){
			alert("로그인 후 삭제가 가능합니다.");
			modal.modal("hide");
			return;
		}
		//현재 모달창에 보이는 사용자와 로그인 사용자가 같은지 확인하기
		let originReplyer = modalInputReplyer.val();
		if(originReplyer != replyer){
			alert("자신의 댓글만 삭제가 가능합니다.");
			modal.modal("hide");
			return;
		}
		
		var rno = modal.data("rno");
		replyService.remove(rno,replyer,
				function(result){
					alert(result);
					//모달창 종료
					modal.modal("hide");
					//전체 댓글 가져오기
					//showList(1); 페이지 나누기 전
					showList(pageNum); //페이지 나누기 후 : 현재 보던 페이지
				},
				function(msg){
					alert("삭제 실패");
		}) 
		
	})
	
	
	//댓글 수정
	$(modalModifyBtn).on("click",function(){
		var rno = modal.data("rno");
		var reply = {
					rno:rno,
					reply:modalInputReply.val(),
					replyer : modalInputReplyer.val()
		};
		//댓글 삭제 버튼이 눌러지면 로그인 여부 확인하기
		if(!replyer){
			alert("로그인 후 수정이 가능합니다.");
			modal.modal("hide");
			return;
		}
		//현재 모달창에 보이는 사용자와 로그인 사용자가 같은지 확인하기
		let originReplyer = modalInputReplyer.val();
		if(originReplyer != replyer){
			alert("자신의 댓글만 수정이 가능합니다.");
			modal.modal("hide");
			return;
		}
		
		replyService.update(reply,function(result){
			alert(result);
			//모달 창 닫기
			modal.modal("hide");
			//전체 댓글 가져오기
			//showList(1); 페이지 나누기 전
			showList(pageNum); //페이지 나누기 후 : 현재 보던 페이지
		},function(error){
			alert("수정 실패");
		})
		
	})
	
 	//댓글 하나 가져오기
 	// 실제로는 li에 이벤트를 걸어야 하지만 댓글이 나중에 생기는 부분이기 때문에
 	// 존재하는 영역에 댓글을 걸고 나중에 생기는 li 태그에 위임하는 방식으로 작성
 	$(".chat").on("click","li",function(){
 		
 		// 현재 클릭된 댓글의 rno 가져오기
 		var rno = $(this).data("rno");
		replyService.get(rno,
			function(result){
				console.log(result);
				
				//도착한 데이터 모달창에 보여주기
				modalInputReply.val(result.reply);
				modalInputReplyer.val(result.replyer);
				modalInputReplyDate.val(replyService.displayTime(result.replydate))
									.attr("readonly","readonly");
				//현재 읽어온 rno 담아주기
				modal.data("rno",result.rno); // "rno"라는 키값에 result.rno의 값을 담아줌
				
				//모달창의 버튼 상태 초기화
				modal.find("button").show();
				
				//작성일 상태 초기화
				modalInputReplyDate.closest("div").show();
				
				//등록 버튼 없애기
				modal.find("button[id='modalRegisterBtn']").hide();
			
				modal.modal("show");
		},function(error){
			alert("가져오기 실패!");
		}) //get 종료 		
 	})
	
})
</script>
<%@include file="../includes/footer.jsp" %>       