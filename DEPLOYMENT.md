# 배포 가이드 (Deployment Guide)

이 문서는 captions.events 프로젝트를 웹에서 테스트할 수 있도록 배포하는 방법을 설명합니다.

## Vercel 배포 (권장)

### 1단계: Vercel 계정 준비

1. [Vercel](https://vercel.com)에 접속하여 GitHub 계정으로 로그인
2. 우측 상단 "Add New" → "Project" 클릭

### 2단계: 프로젝트 Import

1. GitHub 저장소 선택: `elevenlabs/captions.events`
2. 브랜치 선택: `claude/deploy-web-testing-01PodN1LcKzyJnTzaFdBAwJi` (또는 원하는 브랜치)
3. "Import" 클릭

### 3단계: 환경 변수 설정

배포 전에 다음 환경 변수를 설정해야 합니다:

#### 필수 환경 변수

```bash
# Supabase 설정
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# 사이트 URL (배포 후 자동으로 제공되는 URL로 업데이트)
NEXT_PUBLIC_SITE_URL=https://your-app.vercel.app

# ElevenLabs API Key
ELEVENLABS_API_KEY=your-elevenlabs-api-key-here
```

#### Supabase 설정 방법

1. [Supabase Dashboard](https://supabase.com/dashboard)에 접속
2. 프로젝트 선택 → Settings → API
3. `Project URL`을 복사하여 `NEXT_PUBLIC_SUPABASE_URL`에 입력
4. `anon public` 키를 복사하여 `NEXT_PUBLIC_SUPABASE_ANON_KEY`에 입력

#### ElevenLabs API Key 발급

1. [ElevenLabs Settings](https://elevenlabs.io/app/settings/api-keys)에 접속
2. API Key 생성 또는 기존 키 복사
3. `ELEVENLABS_API_KEY`에 입력

### 4단계: 배포

1. "Deploy" 버튼 클릭
2. 배포 완료 대기 (약 2-3분)
3. 배포 완료 후 제공되는 URL 확인

### 5단계: GitHub OAuth 콜백 URL 업데이트

배포 후 반드시 GitHub OAuth 설정을 업데이트해야 합니다:

1. [GitHub Developer Settings](https://github.com/settings/developers)에 접속
2. OAuth App 선택
3. "Authorization callback URL"을 다음과 같이 업데이트:
   ```
   https://your-app.vercel.app/auth/callback
   ```
4. Supabase Dashboard → Authentication → Providers → GitHub에서도 동일하게 업데이트

### 6단계: NEXT_PUBLIC_SITE_URL 업데이트

1. Vercel Dashboard에서 프로젝트 선택
2. Settings → Environment Variables
3. `NEXT_PUBLIC_SITE_URL`을 실제 배포된 URL로 업데이트
   ```
   https://your-app.vercel.app
   ```
4. 재배포 (Deployments 탭 → 최신 배포 → "Redeploy")

## 테스트

배포가 완료되면 다음과 같이 테스트할 수 있습니다:

### 송출자 (Broadcaster)

1. 배포된 사이트에 접속
2. GitHub로 로그인
3. 이벤트 생성
4. `/broadcast/[uid]` 페이지로 이동
5. "Start Recording" 클릭하여 실시간 자막 송출 테스트

### 시청자 (Viewer)

1. `/view/[uid]` 페이지에 접속
2. 실시간 자막 확인
3. Chrome 138+ 사용시 번역 기능 테스트 가능

## 문제 해결

### 빌드 실패

- 환경 변수가 모두 올바르게 설정되었는지 확인
- Vercel 로그에서 오류 메시지 확인

### 인증 실패

- GitHub OAuth 콜백 URL이 올바르게 설정되었는지 확인
- Supabase에서 GitHub Provider가 활성화되었는지 확인

### 자막이 표시되지 않음

- Supabase 연결 확인
- Row Level Security (RLS) 정책 확인
- 브라우저 콘솔에서 오류 확인

### 마이크 권한 오류

- HTTPS 연결 확인 (로컬은 localhost만 가능)
- 브라우저 설정에서 마이크 권한 확인

## 추가 정보

- [SCRIBE_SETUP.md](./SCRIBE_SETUP.md) - ElevenLabs Scribe 설정
- [GITHUB_AUTH_SETUP.md](./GITHUB_AUTH_SETUP.md) - GitHub OAuth 설정
- [TRANSLATION_FEATURE.md](./TRANSLATION_FEATURE.md) - 번역 기능 상세 정보

## 기술 스택

- **프레임워크**: Next.js 16.0.0
- **배포**: Vercel
- **데이터베이스/인증**: Supabase
- **실시간 자막**: ElevenLabs Scribe
- **번역**: Chrome Built-in AI (Translator API)

---

배포 관련 문제가 있으면 이슈를 등록해주세요: https://github.com/elevenlabs/captions.events/issues
