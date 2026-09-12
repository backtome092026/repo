import {createHmac,randomBytes,timingSafeEqual} from "node:crypto";

export const OTP_CHALLENGE_COOKIE="back2me_otp_challenge";
export const OTP_PROOF_COOKIE="back2me_otp_verified";
type TokenPayload={email:string;expires:number;nonce:string;hash?:string;attempts?:number};

function secret(){const value=process.env.OTP_SIGNING_SECRET||process.env.RESEND_API_KEY;if(!value)throw new Error("OTP service is not configured");return value}
function signature(value:string){return createHmac("sha256",secret()).update(value).digest("base64url")}
export function seal(payload:TokenPayload){const body=Buffer.from(JSON.stringify(payload)).toString("base64url");return `${body}.${signature(body)}`}
export function unseal(token?:string):TokenPayload|null{if(!token)return null;const[body,sig]=token.split(".");if(!body||!sig)return null;const expected=signature(body),a=Buffer.from(sig),b=Buffer.from(expected);if(a.length!==b.length||!timingSafeEqual(a,b))return null;try{const payload=JSON.parse(Buffer.from(body,"base64url").toString()) as TokenPayload;return payload.expires>Date.now()?payload:null}catch{return null}}
export function normalizeEmail(email:string){return email.trim().toLowerCase()}
export function newNonce(){return randomBytes(18).toString("base64url")}
export function otpHash(email:string,otp:string,nonce:string){return createHmac("sha256",secret()).update(`${normalizeEmail(email)}:${otp}:${nonce}`).digest("hex")}
export function safeEqual(a:string,b:string){const aa=Buffer.from(a),bb=Buffer.from(b);return aa.length===bb.length&&timingSafeEqual(aa,bb)}
export const secureCookie={httpOnly:true,secure:process.env.NODE_ENV==="production",sameSite:"lax" as const,path:"/"};
