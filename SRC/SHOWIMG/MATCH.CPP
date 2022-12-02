#define TRUE 1
#define FALSE 0

extern "C" int toupper(int);
extern "C" char *strchr(const char *, int);

extern "C" int match(const char *s, const char *p)
{
   /* s = to be tested ,    i = position in s */
   /* p = pattern to match ,j = position in p */

   while (1)
   {
      if (!*s && !*p)
         return TRUE;
      else if (!*p)
         return FALSE;
      else if (*p == '*')
      {
         int k = 0;
         if (!p[1])
           return TRUE;
         else
         {
            while (1)
            {
               int matched = match(s+k,p+1);
               if (matched || !s[k])
                  return matched;
               k++;
            }
         }
      }
      else if ((*p=='?' && *s) || toupper(*p) == toupper(*s))
      {
         s++;
         p++;
      }
      else
         return FALSE;
   }
}

extern "C" int matchset(const char *s, char *p)
{
   int ret = FALSE;
   while (!ret)
   {
      char *breakpos = strchr(p, ';');
      if (breakpos)
         *breakpos = '\0';
      ret = match(s, p);
      if (breakpos)
      {
         *breakpos = ';';
         p = breakpos+1;
      }
      else
         break;
   }
   return ret;

}


