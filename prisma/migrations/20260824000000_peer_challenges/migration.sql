-- CreateEnum
CREATE TYPE "DuelMetric" AS ENUM ('STEPS', 'WORKOUTS', 'WATER', 'STREAK', 'CUSTOM');

-- CreateEnum
CREATE TYPE "DuelStatus" AS ENUM ('PENDING', 'ACTIVE', 'COMPLETED', 'DECLINED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ProgressSource" AS ENUM ('SELF_REPORTED', 'HEALTH_KIT', 'PARTNER_CHECKIN');

-- CreateEnum
CREATE TYPE "ChallengePrivacy" AS ENUM ('EVERYONE', 'CONNECTIONS', 'NOBODY');

-- CreateEnum
CREATE TYPE "DuelEventKind" AS ENUM ('ACCEPTED', 'PROGRESS', 'GOAL_MET', 'TOOK_LEAD', 'COMPLETED');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "challengePrivacy" "ChallengePrivacy" NOT NULL DEFAULT 'EVERYONE',
ADD COLUMN     "username" TEXT;

-- CreateTable
CREATE TABLE "Duel" (
    "id" TEXT NOT NULL,
    "challengerId" TEXT NOT NULL,
    "opponentId" TEXT NOT NULL,
    "metric" "DuelMetric" NOT NULL,
    "target" INTEGER NOT NULL,
    "durationDays" INTEGER NOT NULL,
    "titleEn" TEXT,
    "titleAr" TEXT,
    "status" "DuelStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" TIMESTAMP(3),
    "endsAt" TIMESTAMP(3),
    "settledAt" TIMESTAMP(3),
    "winnerId" TEXT,

    CONSTRAINT "Duel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DuelEntry" (
    "id" TEXT NOT NULL,
    "duelId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "day" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL DEFAULT 0,
    "date" DATE NOT NULL,
    "source" "ProgressSource" NOT NULL DEFAULT 'SELF_REPORTED',
    "metAt" TIMESTAMP(3),

    CONSTRAINT "DuelEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DuelEvent" (
    "id" TEXT NOT NULL,
    "duelId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "kind" "DuelEventKind" NOT NULL,
    "amount" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DuelEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Connection" (
    "id" TEXT NOT NULL,
    "followerId" TEXT NOT NULL,
    "followingId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Connection_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Duel_challengerId_status_idx" ON "Duel"("challengerId", "status");

-- CreateIndex
CREATE INDEX "Duel_opponentId_status_idx" ON "Duel"("opponentId", "status");

-- CreateIndex
CREATE INDEX "Duel_status_endsAt_idx" ON "Duel"("status", "endsAt");

-- CreateIndex
CREATE INDEX "DuelEntry_duelId_userId_idx" ON "DuelEntry"("duelId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "DuelEntry_duelId_userId_day_key" ON "DuelEntry"("duelId", "userId", "day");

-- CreateIndex
CREATE INDEX "DuelEvent_duelId_createdAt_idx" ON "DuelEvent"("duelId", "createdAt");

-- CreateIndex
CREATE INDEX "Connection_followingId_idx" ON "Connection"("followingId");

-- CreateIndex
CREATE UNIQUE INDEX "Connection_followerId_followingId_key" ON "Connection"("followerId", "followingId");

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE INDEX "User_username_idx" ON "User"("username");

-- AddForeignKey
ALTER TABLE "Duel" ADD CONSTRAINT "Duel_challengerId_fkey" FOREIGN KEY ("challengerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Duel" ADD CONSTRAINT "Duel_opponentId_fkey" FOREIGN KEY ("opponentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DuelEntry" ADD CONSTRAINT "DuelEntry_duelId_fkey" FOREIGN KEY ("duelId") REFERENCES "Duel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DuelEntry" ADD CONSTRAINT "DuelEntry_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DuelEvent" ADD CONSTRAINT "DuelEvent_duelId_fkey" FOREIGN KEY ("duelId") REFERENCES "Duel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DuelEvent" ADD CONSTRAINT "DuelEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Connection" ADD CONSTRAINT "Connection_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Connection" ADD CONSTRAINT "Connection_followingId_fkey" FOREIGN KEY ("followingId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
