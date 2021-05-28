<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@include file="../includes/header.jsp" %>
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Board List</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Board List Page
                            <button id='regBtn' type='button' class='btn btn-xs pull-right btn-success' onclick="location.href='/board/register'"> Register New Board</button>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <table class="table table-striped table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th>번 호</th>
                                        <th>제 목</th>
                                        <th>작성자</th>
                                        <th>작성일</th>
                                        <th>수정일</th>
                                    </tr>							
                                </thead>
								<!-- 게시판 리스트 반복문 -->
								<c:forEach var="vo" items="${list}">
								<tbody>
                                    <tr>
                                        <td>${vo.bno}</td>
                                        <td><a href="<c:out value='${vo.bno}'/>" class="move">${vo.title}</a><strong>[${vo.replycnt}]</strong></td>
                                        <td>${vo.writer}</td>
                                        <td><fmt:formatDate pattern="yyyy-MM-dd HH:mm" value="${vo.regdate}"/></td>
                                        <td><fmt:formatDate pattern="yyyy-MM-dd HH:mm" value="${vo.updatedate}"/></td>
                                    </tr>
                                </tbody>
                                </c:forEach>							
                            </table>
							<div class="row"> <!-- start search -->
                            	<div class="col-md-12">
                            	  <div class="col-md-8"><!--search Form-->
                            	  	<form action="" id="searchForm">
                            	  	<input type="hidden" name="pageNum" value="${cri.pageNum}" />
                            	  	<input type="hidden" name="amount" value="${cri.amount}" />
                            			<select name="type" id="">
                            				<option value=""<c:out value="${empty cri.type ?'selected':'' }"/>>---------</option>
                            				<option value="T" <c:out value="${cri.type =='T' ?'selected':'' }"/>>제목</option>
                            				<option value="C" <c:out value="${cri.type =='C' ?'selected':'' }"/>>내용</option>
                            				<option value="W" <c:out value="${cri.type =='W' ?'selected':'' }"/>>작성자</option>
                            				<option value="TC" <c:out value="${cri.type =='TC' ?'selected':'' }"/>>제목 or 내용</option>
                            				<option value="TW" <c:out value="${cri.type =='TW' ?'selected':'' }"/>>제목 or 작성자</option>
                            				<option value="TCW" <c:out value="${cri.type =='TCW' ?'selected':'' }"/>>제목 or 내용 or 작성자</option>
                            			</select>
                            			<input type="text" name="keyword" value="${cri.keyword}"/>
                            			<button class="btn btn-default">검색</button>
                            		 </form>
                            	   </div>
                            	   <div class="col-md-2 col-md-offset-2">
                            	   	<!--페이지 목록 갯수 지정하는 폼-->
                            	   	<select class="form-control" name="amount">
                            	   		<option value="10" <c:out value="${cri.amount == '10'?'selected':'' }"/>>10</option>
                            	   		<option value="20" <c:out value="${cri.amount == '20'?'selected':'' }"/>>20</option>
                            	   		<option value="30" <c:out value="${cri.amount == '30'?'selected':'' }"/>>30</option>
                            	   		<option value="40" <c:out value="${cri.amount == '40'?'selected':'' }"/>>40</option>
                            	   	</select>
								  </div>
                             	 </div>                             	 
                      		 </div><!-- end search -->
                            <!-- start Pagination -->
                            <div class="text-center">
                            	<ul class="pagination">
                            	<c:if test="${pageVO.prev}">
                            		<li class="paginate_button previous"><a href="${pageVO.startPage-1}">Previous</a></li>
                            	</c:if>
                            	<c:forEach var="idx" begin="${pageVO.startPage}" end="${pageVO.endPage}">
                            		<li class="paginate_button ${pageVO.cri.pageNum==idx?'active':''}"><a href="${idx}">${idx}</a></li>
                            	</c:forEach>
                            	<c:if test="${pageVO.next}">
                            		<li class="paginate_button next"><a href="${pageVO.endPage+1}">Next</a></li>
                            	</c:if>
                            	</ul>
                            </div>
                            <!-- end Pagination -->   
                            </div>
                            <!-- end panel-body -->
                        </div>
                        <!-- end panel -->
                    </div>                   
                </div>               
            <!-- /.row -->
<%-- 페이지번호를 누르면 동작하는 폼 --%>
<form action="list" id="actionForm">
	<input type="hidden" name="pageNum" value="${pageVO.cri.pageNum}" />
	<input type="hidden" name="amount" value="${pageVO.cri.amount}" />
	<input type="hidden" name="type" value="${cri.type}" /> <!-- pageVO.cri.type 도 가능-->
	<input type="hidden" name="keyword" value="${cri.keyword}" />
</form>

<!-- 모달 추가 -->
<div class="modal" tabindex="-1" role="dialog" id="myModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">게시글 등록</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>처리가 완료되었습니다.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- 스크립트 -->
<script>
	$(function(){
		let result = '${result}';
		checkModal(result);
		history.replaceState({}, null, null); // 기존 내역을 지우고 기본값으로 새로 uri를 만듬
		
		function checkModal(result){
			if(result === '' || history.state){ // 히스토리가 있으면 function을 빠져나감.history.state => {}
				return;
			}
			if(parseInt(result)>0){
				$(".modal-body").html("게시글 "+parseInt(result)+" 번이 등록되었습니다.");
			}
			$("#myModal").modal("show");
		}
		
		// 사용자가 페이지 번호를 누르면 동작하는 스크립트
		let actionForm = $("#actionForm");
		$(".paginate_button a").click(function(e) {
			// a 태그는 기본적으로 누르면 무조건 get방식으로 보낸다
			// 그래서 a 태그의 동작을 막아야 한다.
			e.preventDefault();
			// 전송해야 할 폼 가져온 후 pageNum의 값을 변경한 후
			actionForm.find("input[name='pageNum']").val($(this).attr("href"));
			// 폼 전송하기
			actionForm.submit();
		})
		
		$(".form-control").change(function() {
			// 전송해야 할 폼 가져온 후 amount 값을 변경한 후
			actionForm.find("input[name='amount']").val($(this).val()); // this==form-control
			// 폼 전송하기
			actionForm.submit();
		})
		
		//타이틀 클릭 시 페이지나누기 정보가 있는 폼 보내기
		$(".move").click(function(e){
			// 37번줄에
			// <a href="read?bno=${vo.bno}&pageNum=${cri.pageNum}&amount=${cri.amount}">${vo.title}</a>
			// 이것을 대체
			
			e.preventDefault();  //a 태그의 기능을 막는 기능
			actionForm.append("	<input type='hidden' name='bno' value='"+$(this).attr("href")+"'/>");
			actionForm.attr('action','read');
			actionForm.submit();
		})
		
		$(".btn-default").click(function(){
			let searchForm = $("#searchForm");
			//type과 keyword가 비어 있는지 확인하고
			//비어 있으면 메시지를 띄어준 후 return
			let type = $("select[name='type']").val();
			let keyword = $("input[name='keyword']").val();
			if(type === '' || keyword === ''){
				$(".modal-body").html("검색 조건 및 검색란을 확인하세요");
				$("#myModal").modal("show");
				return false;
			}else{
				//모두 입력이 된 경우 폼 전송
				searchForm.find("input[name='pageNum']").val("1");
				searchForm.submit();
			}		
		})
		
	})
</script>
<%@include file="../includes/footer.jsp" %>       