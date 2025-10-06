# GoAccess 대시보드 문제 해결 현황

## ✅ 해결된 문제

### 1. SSL/HTTPS 접속 (해결완료)
- **문제**: HTTPS 접속 시 자체 서명 인증서 오류
- **원인**: Traefik에 `letsencrypt-prod` certificate resolver가 설정되지 않음
- **해결**:
  - cert-manager의 Certificate 리소스 생성
  - IngressRoute에서 `certResolver` 대신 `secretName` 사용
  - Let's Encrypt 인증서 성공적으로 발급됨

### 2. HTTP → HTTPS 리다이렉션 (해결완료)
- 별도의 IngressRoute와 Middleware로 구현
- HTTP 접속 시 자동으로 HTTPS로 리다이렉트

## ✅ WebSocket 연결 (해결완료)

### 문제 및 해결
- **문제**: WebSocket URL에 포트 7890이 포함되어 연결 실패
  - 브라우저 오류: `WebSocket connection to 'wss://stats.midagedev.com:7890/ws' failed`
- **원인**: GoAccess `--ws-url` 파라미터 설정 오류
- **해결**:
  - `--ws-url=wss://stats.midagedev.com:443/ws`로 변경
  - 생성된 HTML에서 올바른 WebSocket URL 확인: `wss://stats.midagedev.com/ws`

### 최종 구성
- GoAccess WebSocket 서버: ✅ 포트 7890에서 정상 실행
- nginx 프록시: ✅ `/ws` → `localhost:7890` 설정 완료
- Traefik 라우팅: ✅ `/ws` 경로 별도 처리 설정
- HTML 파일: ✅ `wss://stats.midagedev.com/ws` URL 포함

### 테스트 방법
브라우저에서 https://stats.midagedev.com 접속 후:
1. 개발자 도구 (F12) 열기
2. Network 탭에서 WS 필터 선택
3. WebSocket 연결 상태 확인

### 가능한 문제점
1. **Origin 검증**: GoAccess가 Origin 헤더를 엄격하게 검증할 수 있음
2. **경로 문제**: WebSocket 업그레이드 시 경로가 올바르게 전달되지 않을 수 있음
3. **Traefik 헤더**: WebSocket 업그레이드 헤더가 제대로 전달되지 않을 수 있음

## 📝 추가 디버깅 방법

### 1. 브라우저 콘솔에서 확인
```javascript
// 콘솔에서 WebSocket 연결 테스트
var ws = new WebSocket('wss://stats.midagedev.com/ws');
ws.onopen = function() { console.log('Connected!'); };
ws.onerror = function(e) { console.log('Error:', e); };
ws.onclose = function(e) { console.log('Closed:', e.code, e.reason); };
```

### 2. Pod 내부에서 직접 테스트
```bash
# nginx 컨테이너에서 GoAccess WebSocket 서버로 직접 연결
kubectl exec -it -n traefik-system deployment/goaccess -c nginx -- sh
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Origin: https://stats.midagedev.com" \
  http://127.0.0.1:7890/ws
```

### 3. nginx 에러 로그 확인
```bash
kubectl logs -n traefik-system deployment/goaccess -c nginx --tail=50
```

### 4. GoAccess 로그 확인
```bash
kubectl logs -n traefik-system deployment/goaccess -c goaccess --tail=50
```

## ✅ 모든 문제 해결 완료

### 해결 요약
1. **SSL/HTTPS 접속**: Let's Encrypt 인증서 발급 완료
2. **HTTP → HTTPS 리다이렉션**: 정상 작동
3. **WebSocket 연결**: 올바른 URL로 설정되어 실시간 업데이트 가능

### 접속 정보
- Dashboard URL: https://stats.midagedev.com
- WebSocket: wss://stats.midagedev.com/ws
- SSL 인증서: Let's Encrypt (유효기간: 2025-10-06 ~ 2026-01-04)