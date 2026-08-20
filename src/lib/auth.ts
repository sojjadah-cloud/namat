import NextAuth from 'next-auth';
import Credentials from 'next-auth/providers/credentials';
import { cookies } from 'next/headers';
import { prisma } from '@/lib/prisma';
import { normalizePhone, verifyChallenge, OTP_COOKIE } from '@/lib/otp';

/**
 * NAMAT is phone-first: there is no password anywhere in the product. The
 * credentials provider here is a verification step, not a login form — the
 * work of proving the number happened when the code was issued, and this only
 * checks the signed challenge and resolves it to an account.
 */
export const { handlers, auth, signIn, signOut } = NextAuth({
  session: { strategy: 'jwt' },
  pages: { signIn: '/login' },
  providers: [
    Credentials({
      id: 'phone',
      name: 'Phone',
      credentials: {
        phone: { label: 'Phone', type: 'tel' },
        code: { label: 'Code', type: 'text' },
      },
      async authorize(credentials) {
        const rawPhone = credentials?.phone;
        const code = credentials?.code;
        if (typeof rawPhone !== 'string' || typeof code !== 'string') return null;

        const phone = normalizePhone(rawPhone);
        const jar = await cookies();
        if (!verifyChallenge(jar.get(OTP_COOKIE)?.value, phone, code)) return null;

        // A verified number is an account. Signing up and logging in are the
        // same act; the only difference is whether we already knew the number.
        const user = await prisma.user.upsert({
          where: { phone },
          create: { phone },
          update: {},
        });

        return { id: user.id, name: user.name, email: user.email, image: user.image };
      },
    }),
  ],
  callbacks: {
    jwt({ token, user }) {
      if (user) token.id = user.id;
      return token;
    },
    session({ session, token }) {
      if (session.user && token.id) session.user.id = token.id as string;
      return session;
    },
  },
});
