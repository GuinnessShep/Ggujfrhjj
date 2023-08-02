import discord
from discord.ext import commands
from transformers import pipeline

TOKEN = input("Enter your bot token: ")
MODEL_ID = "gpt2"  # You can replace this with your desired model identifier
PREFIX = "!"

intents = discord.Intents.default()
bot = commands.Bot(command_prefix=PREFIX, intents=intents)

# Load the chat model
llama_chat = pipeline("text-generation", model=MODEL_ID)

@bot.event
async def on_ready():
    print(f'{bot.user} has connected to Discord!')

@bot.command(name='chat', help='Chat with a model')
async def chat(ctx, *, question):
    response = llama_chat(question)[0]['generated_text']
    await ctx.send(response)

bot.run(TOKEN)
