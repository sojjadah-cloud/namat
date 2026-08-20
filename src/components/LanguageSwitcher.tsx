"use client";

import { Button } from "@/components/ui/button";
import { Globe } from "lucide-react";
import { useLocale } from "next-intl";
import { usePathname, useRouter } from "@/i18n/routing";

export function LanguageSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  const toggleLanguage = () => {
    const nextLocale = locale === "en" ? "ar" : "en";
    router.replace(pathname, { locale: nextLocale });
  };

  return (
    <Button variant="ghost" size="sm" onClick={toggleLanguage} className="gap-2 font-medium">
      <Globe className="h-4 w-4" />
      {locale === "en" ? "العربية" : "English"}
    </Button>
  );
}
