<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/mycss.css" />
<%@include file="../includes/header.jsp" %>
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Board Register</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>            
            <div class="row">
                <div class="col-lg-12">
                	<div class="panel panel-default">
                        <div class="panel-heading">
                           Board Register Page
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                			<form action="" method="post" role="form">
                				<div class="form-group">
                					<label>Title</label>
                					<input class="form-control" name="title">                				
                				</div>  
                				<div class="form-group">
                					<label>Content</label>
                					<textarea class="form-control" rows="3" name="content"></textarea>               				
                				</div> 
                				<div class="form-group">
                					<label>Writer</label>
                					<input class="form-control" name="writer" value='<sec:authentication property="principal.username"/>' readonly>                				
                				</div>  
                				<button type="submit" class="btn btn-default">Submit</button>              			
                				<button type="reset" class="btn btn-default">reset</button>      
                				<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />        			
                			</form>
                		</div>
                	</div>
                </div>
            </div> 
<!-- ???????????? ?????? -->
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading">?????? ??????</div>
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
<script>
$(function(){
	
	$("button[type='submit']").click(function(e){
		//submit ?????? ?????? ??????
		e.preventDefault();
		//????????? ?????? + ?????? ?????? ???????????? ??????
		//?????? ?????? ?????? ?????? => ?????? uploadResult??? ul??? li??? ???????????? ????????? ????????? ??????
		let str = "";
		
		$(".uploadResult ul li").each(function(i,ele){
			let job = $(ele);
			
			str += "<input type='hidden' name='attachList["+i+"].uuid' value='"+job.data("uuid")+"'>";
			str += "<input type='hidden' name='attachList["+i+"].uploadPath' value='"+job.data("path")+"'>";
			str += "<input type='hidden' name='attachList["+i+"].fileName' value='"+job.data("filename")+"'>";
			str += "<input type='hidden' name='attachList["+i+"].fileType' value='"+job.data("type")+"'>";
		})
		console.log(str);
		
		//?????? ??? ??????
		$("form[role='form']").append(str).submit();
	})
	
	//csrf ?????? ??? ??????
	let csrfHeaderName = "${_csrf.headerName}";
	let csrfTokenValue = "${_csrf.token}";
	
	$("input[type='file']").change(function(){
		//form??? ????????? ???????????? ????????? ??? ??????
		// key, value ????????? ????????? ??? ?????? ?????? 
		let formData = new FormData();
		
		// ???????????? ?????? ????????????
		let uploadFile = $("input[name='uploadFile']");
		console.log(uploadFile);
		let files = uploadFile[0].files;
		console.log(files);
		
		//form??? ????????? ?????????
		for(var i=0;i<files.length;i++){
			if(!checkExtension(files[i].name, files[i].size)){
				return false;
			}
			formData.append("uploadFile",files[i]); //key = "uploadFile", value = files??? ??? ??????
		}
		console.log(formData);
		// processData : ???????????? query string(uploadFile = ?????????.txt)??? ??????
		//				  ???????????? application/x-www-form-urlencoded??? true?????? ?????????
		//				 false??? ??????
		// contentType : ???????????? application/x-www-form-urlencoded => true.
		//               ????????? ????????? enctype??? multipart/form-data??? ??????????????? ????????? false.
		$.ajax({
			url:'/uploadAjax',
			type:'post',
			beforeSend : function(xhr){
				xhr.setRequestHeader(csrfHeaderName, csrfTokenValue);
			},
			processData : false,
			contentType : false,
			data : formData,
			success:function(result){
				//alert(result);
				console.log(result);
				showUploadFile(result);
				$("input[name='uploadFile']").val("");
			},
			error:function(xhr,status,error){
				alert(xhr.responseText);
			}
		})
		
	})
	
	//???????????? ?????? / ?????? ??????
	function checkExtension(fileName, fileSize){
		let regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
		let maxSize = 2097152;
		
		if(fileSize > maxSize){
			alert("?????? ????????? ??????");
			return false;
		}
		if(regex.test(fileName)){
			alert("?????? ????????? ????????? ????????? ??? ??? ????????????.");
			return false;
		}
		return true;
	}
	
	//????????? ??? ?????? ????????????
	function showUploadFile(uploadResultArr){
		let str = "";
		// ????????? ????????? ?????? ????????????
		let uploadResult = $(".uploadResult ul");
		$(uploadResultArr).each(function(i, element) {
			if(element.fileType){ // true = ???????????????
				//????????? ????????? ??????
				var fileCallpath = encodeURIComponent(element.uploadPath+"\\s_"+element.uuid+"_"+element.fileName);
				//?????? ????????? ??????
				var oriPath = element.uploadPath+"\\"+element.uuid+"_"+element.fileName;
				oriPath = oriPath.replace(new RegExp(/\\/g), "/");
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<a href=\"javascript:showImage(\'"+oriPath+"\')\">";
				str += "<img src='/display?fileName="+fileCallpath+"'><div>"+element.fileName+"</a>";
				str += " <button type='button' class='btn btn-danger btn-circle btn-sm' data-file='"+fileCallpath +"' data-type='image'>";
				str += "<i class='fa fa-times'></i></button>"; 
				str += "</div></li>";
			}else{  // ?????? ??????
				var fileCallPath = encodeURIComponent(element.uploadPath+"\\"+element.uuid+"_"+element.fileName);
				str += "<li data-path='"+element.uploadPath + "' data-uuid='"+element.uuid+"'";
				str += " data-filename='"+element.fileName+"' data-type='"+element.fileType+"'>";
				str += "<a href='/download?fileName="+fileCallPath +"'>";
				str += "<img src='/resources/img/attach.png'><div>"+element.fileName+"</a>";
				str += " <button type='button' class='btn btn-warning btn-circle btn-sm' data-file='"+fileCallpath +"' data-type='file'>";
				str += "<i class='fa fa-times'></i></button>"; 
				str += "</div></li>";
			}
		})
		uploadResult.append(str);
	}
	
	// x??? ????????? ?????? ??????
	$(".uploadResult").on("click","button",function(e){
		
		let targetFile = $(this).data("file");
		let type = $(this).data("type");
		let targetLi = $(this).closest("li");
		
		$.ajax({
			url : '/deleteFile',
			data : {
				fileName : targetFile,
				type : type
			},
			beforeSend : function(xhr){
				xhr.setRequestHeader(csrfHeaderName, csrfTokenValue);
			},
			type : 'post',
			success:function(result){
				targetLi.remove();
			}
		})
		e.stopPropagation();
	})
})
</script>
<%@include file="../includes/footer.jsp" %>       