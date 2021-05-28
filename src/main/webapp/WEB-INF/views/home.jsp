<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ page session="false" %>
<html>
<head>
	<title>Home</title>
</head>
<body>
<h1>
	스프링 게시판 
</h1>
	<%-- 로그인 정보가 있다면 로그아웃 버튼을 보이게 하고, 없다면 로그인 버튼 --%>
	<sec:authorize access="isAnonymous()">
		<a href="/member/login">로그인</a>
	</sec:authorize>
	<sec:authorize access="isAuthenticated()">
		<form action="/member/logout" method="post">
			<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
			<button>로그아웃</button>
		</form>
	</sec:authorize>
</body>
</html>

