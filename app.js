const express = require("express");
const app = express();

// 컨테이너 내부에서는 8080 포트를 사용합니다.
const PORT = 8080;

// 누군가 우리 웹사이트의 가장 기본 주소('/')로 접속하면 실행되는 부분입니다.
app.get("/", (req, res) => {
  res.send("Hello, DevOps with Express and Jenkins!! 44");
});

// 8080 포트에서 웹서버를 시작하고, 성공하면 메시지를 보여줍니다.
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
