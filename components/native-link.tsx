import {forwardRef,type AnchorHTMLAttributes} from "react";

type NativeLinkProps=Omit<AnchorHTMLAttributes<HTMLAnchorElement>,"href">&{
  href:string;
  prefetch?:boolean;
};

const NativeLink=forwardRef<HTMLAnchorElement,NativeLinkProps>(function NativeLink({href,prefetch:_,...props},ref){
  return <a ref={ref} href={href} {...props}/>;
});

export default NativeLink;
