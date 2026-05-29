#!/usr/bin/env bun

const API_KEY = "KEY HERE!";
const MODEL = "gemini-2.5-flash"; // Default model

if (!API_KEY) {
  console.error("Error: Please set GEMINI_API_KEY");
  process.exit(1);
}

const question = Bun.argv.slice(2).join(" ");

if (!question) {
  console.error("Usage: ai <question>");
  process.exit(1);
}

const SYSTEM_PROMPT = `
You are a helpful assistant that answers questions based on the provided context.
USE NO MARKDOWN, USE ONLY PLAIN TEXT.
`;

async function askGemini(prompt: string) {
  prompt = SYSTEM_PROMPT + "\n\n" + prompt;
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}`;

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
      }),
    });

    const data = (await response.json()) as { candidates: any[]; error: any };

    if (data.error) {
      throw new Error(data.error.message);
    }

    const text = data.candidates[0].content.parts[0].text;
    console.log(text);
  } catch (err: any) {
    console.error("API Error:", err.message);
  }
}

askGemini(question);
