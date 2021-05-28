<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <!-- 합쳐지고 최소화된 최신 CSS -->

<%--
	custom Login page 작성 규칙
	1. method = "post", action="/login" 으로 주기
	2. csrf 토큰 값 무조건 포함
	3. 아이디를 입력받는 부분의 이름은 반드시 username으로 하기
	4. 비밀번호를 입력받는 부분의 이름은 반드시 password로 하기
	
 --%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
<link rel="stylesheet" href="/resources/css/login.css" />
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<form action="/login" method="post" class="form-signin">
		<h1 class="h3 mb-3 font-weight-normal">Sign in</h1>
		<div>
			<label for="id" class="sr-only">아이디</label>
			<input type="text" name="username" placeholder="아이디" class="form-control" 
					required="required" autofocus="autofocus" />
		</div>
		<div>
			<label for="password" class="sr-only">비밀번호</label>
			<input type="password" name="password" class="form-control" 
					placeholder="비밀번호" required="required" />
		</div>
		<div class="checkbox mb-3">
			<label for="">
				<input type="checkbox" name="remember-me" />Remember me
			</label>
		</div>
		<div>
			<button class="btn btn-primary btn-block">Sign in</button>
		</div>
		<div>${error}</div>
		<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	</form>
</body>
</html>