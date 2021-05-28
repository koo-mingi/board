<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/mycss.css" />
<%@include file="../includes/header.jsp" %>
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Board Modify</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>            
            <div class="row">
                <div class="col-lg-12">
                	<div class="panel panel-default">
                        <div class="panel-heading">
                           Board Modify Page
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                			<form action="" method="post" role="form" id="modifyForm">
                				<div class="form-group">
                					<label>Bno</label>
                					<input class="form-control" name="bno" value="${board.bno}" readonly="readonly">                				
                				</div> 
                				<div class="form-group">
                					<label>Title</label>
                					<input class="form-control" name="title" value="${board.title}">                				
                				</div>  
                				<div class="form-group">
                					<label>Content</label>
                					<textarea class="form-control" rows="3" name="content">${board.content}</textarea>               				
                				</div> 
                				<div class="form-group">
                					<label>Writer</label>
                					<input class="form-control" name="writer" readonly="readonly" value="${board.writer}">                 				
                				</div>
                				<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                				<sec:authentication property="principal" var="info"/>
                				<sec:authorize access="isAuthenticated()">
                				<c:if test="${info.username == board.writer}">
	                				<button type="submit" data-oper='modify' class="btn btn-default">Modify</button>              			
	                				<button type="submit" data-oper='remove' class="btn btn-danger">Remove</button>              			
                				</c:if>
                				</sec:authorize>      
                				<button type="submit" data-oper='list' class="btn btn-info">List</button>              			
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
				<div class="form-group uploadDiv">
					<input type="file" name="uploadFile" multiple="multiple" />
				</div>
				<div class="uploadResult">
					<ul></ul>				
				</div>
			</div>
		</div>
	</div>
</div>
<%-- remove와 list를 위한 폼--%>
<form method="post" id = "myForm">
	<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	<input type="hidden" name="bno" value="${board.bno}" />
	<input type="hidden" name="writer" value="${board.writer}" />
	<input type="hidden" name="pageNum" value="${cri.pageNum}" />
	<input type="hidden" name="amount" value="${cri.amount}" />
	<input type="hidden" name="type" value="${cri.type}" />
	<input type="hidden" name="keyword" value="${cri.keyword}" />
</form>
			
<%-- 스크립트 --%>
<script>
// 이미지 클릭 시 확대
function showImage(fileCallPath){
	$(".bigPictureWrapper").css("display","flex").show();
	
	$(".bigPicture").html("<img src='/display?fileName="+fileCallPath+"'>")
					.animate({width:'100%',height:'100%'},1000);
}

$(function(){
	
	//csrf 토큰 값 생성
	let csrfHeaderName = "${_csrf.headerName}";
	let csrfTokenValue = "${_csrf.token}";
	
	$("input[type='file']").change(function(){
		//form의 형태로 데이터를 구성할 수 있음
		// key, value 형태로 구성할 수 있게 해줌 
		let formData = new FormData();
		
		// 첨부파일 목록 가져오기
		let uploadFile = $("input[name='uploadFile']");
		console.log(uploadFile);
		let files = uploadFile[0].files;
		console.log(files);
		
		//form의 형태로 붙이기
		for(var i=0;i<files.length;i++){
			if(!checkExtension(files[i].name, files[i].size)){
				return false;
			}
			formData.append("uploadFile",files[i]); //key = "uploadFile", value = files의 각 형태
		}
		console.log(formData);
		// processData : 데이터를 query string(uploadFile = 테스트.txt)로 변환
		//				  기본값은 application/x-www-form-urlencoded로 true이기 때문에
		//				 false로 지정
		// contentType : 기본값은 application/x-www-form-urlencoded => true.
		//               파일의 경우에 enctype은 multipart/form-data로 보내야하기 때문에 false.
		$.ajax({
			url:'/uploadAjax',
			type:'post',
			processData : false,
			contentType : false,
			data : formData,
			beforeSend : function(xhr){
				xhr.setRequestHeader(csrfHeaderName, csrfTokenValue);
			},
			success:function(result){
				//alert(result);
				console.log(result);
				showUploadFile(result);
			},
			error:function(xhr,status,error){
				alert(xhr.responseText);
			}
		})
		
	})
	
	//업로드 된 파일 보여주기
	function showUploadFile(uploadResultArr){
		let str = "";
		// 결과를 보여줄 영역 가져오기
		let uploadResult = $(".uploadResult ul");
		$(uploadResultArr).each(function(i, element) {
			if(element.fileType){ // true = 이미지파일
				//썸네일 이미지 경로
				var fileCallpath = encodeURIComponent(element.uploadPath+"\\s_"+element.uuid+"_"+element.fileName);
				//원본 이미지 경로
				var oriPath = element.uploadPath+"\\"+element.uuid+"_"+element.fileName;
				oriPath = oriPath.replace(new RegExp(/\\/g), "/");
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<a href=\"javascript:showImage(\'"+oriPath+"\')\">";
				str += "<img src='/display?fileName="+fileCallpath+"'><div>"+element.fileName+"</a>";
				str += " <button type='button' class='btn btn-danger btn-circle btn-sm'>";
				str += "<i class='fa fa-times'></i></button>"; 
				str += "</div></li>";
			}else{  // 일반 파일
				var fileCallPath = encodeURIComponent(element.uploadPath+"\\"+element.uuid+"_"+element.fileName);
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<a href='/download?fileName="+fileCallPath +"'>";
				str += "<img src='/resources/img/attach.png'><div>"+element.fileName+"</a>";
				str += " <button type='button' class='btn btn-warning btn-circle btn-sm'>";
				str += "<i class='fa fa-times'></i></button>"; 
				str += "</div></li>";
			}
		})
		uploadResult.append(str);
	}
	
	
	//첨부파일 제한 / 크기 제한
	function checkExtension(fileName, fileSize){
		let regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
		let maxSize = 2097152;
		
		if(fileSize > maxSize){
			alert("파일 사이즈 초과");
			return false;
		}
		if(regex.test(fileName)){
			alert("해당 종류의 파일은 업로드 할 수 없습니다.");
			return false;
		}
		return true;
	}
	
	
	
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
				str += "<div><span><a>"+element.fileName+"</span>";
				str += " <button type='button' class='btn btn-danger btn-circle btn-sm' data-file='"+fileCallpath +"' data-type='image'>";
				str += "<i class='fa fa-times'></i></button>"; 
				str += "</div>";
				str += "<img src='/display?fileName="+fileCallpath +"'></a></li>";
			}else{ //일반파일
				var fileCallpath = encodeURIComponent(element.uploadPath+"\\"+element.uuid+"_"+element.fileName);
			
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<div><span><a>"+element.fileName+"</span>";
				str += " <button type='button' class='btn btn-danger btn-circle btn-sm' data-file='"+fileCallpath +"' data-type='file'>";
				str += "<i class='fa fa-times'></i></button>"; 
				str +="</div>";
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
	
	// x를 누르면 목록에서 삭제하기
	$(".uploadResult").on("click","button",function(e){
		
		if(confirm("파일을 삭제하시겠습니까?")){
			let targetLi = $(this).closest("li");
			targetLi.remove();
		}
		e.stopPropagation();
	})
	
	
	
	
	
	//------------------------------------- 첨부파일 스크립트 종료
})

$(function(){
	let form = $("#myForm");
				
	$("button").click(function(e){
		// 버튼은 모두 submit형태이기 때문에 submit 속성 중지시키기
		e.preventDefault();
		
		// 버튼이 눌러지면 어느 버튼에서 온 것인지 알아내기
		let oper = $(this).data("oper");
		
		// modify 버튼이 눌러지면 수정 폼 보내기
		if(oper==='modify'){
			//let modifyForm = $("#modifyForm");
			//modifyForm.submit();
			form = $("form[role=form]");
			
			// 첨부파일 정보를 수집해서 수정 버튼이 눌러지면 다시 보내기
			let str = "";
		
			$(".uploadResult ul li").each(function(i,ele){
				let job = $(ele);
				
				str += "<input type='hidden' name='attachList["+i+"].uuid' value='"+job.data("uuid")+"'>";
				str += "<input type='hidden' name='attachList["+i+"].uploadPath' value='"+job.data("path")+"'>";
				str += "<input type='hidden' name='attachList["+i+"].fileName' value='"+job.data("filename")+"'>";
				str += "<input type='hidden' name='attachList["+i+"].fileType' value='"+job.data("type")+"'>";
			})
			console.log(str);
			form.append(str);
			
		}else if(oper==='list'){
			// list가 눌러지면 bno은 삭제하고 myForm 보내기
			form.attr('action','list');
			form.attr('method','get');
			form.find("input[name='bno']").remove();	
		}else if(oper==='remove'){
			// Remove가 눌러지면 myForm보내기
			form.attr('action','remove');
		}
		form.submit();
	})
})
			
			</script>
<%@include file="../includes/footer.jsp" %>       