import OpenAI from 'openai'
import { Pinecone, PineconeRecord, RecordMetadata } from '@pinecone-database/pinecone'
import axios from 'axios'
import PDFParser from 'pdf2json'





// Initialize OpenAI client
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
    fetch: globalThis.fetch
})
const pinecone = new Pinecone({
    apiKey: process.env.PINECONE_API_KEY!
})

const index = pinecone.index(process.env.PINECONE_INDEX || 'meridian').namespace('')

const chunkText = (text: string, chunkSize = 500, overlap = 50): string[] => {
    const words = text.split(' ')
    const chunks: string[] = []
    let i = 0
    while (i < words.length) {
        const chunk = words.slice(i, i + chunkSize).join(' ')
        chunks.push(chunk)
        i += chunkSize - overlap
    }
    return chunks.filter(chunk => chunk.trim().length > 0)
}

export const ingestPDF = async (
    assignmentId: string,
    courseId: string,
    fileUrl: string
) => {
    try {
        console.log(`Starting ingestion for assignment: ${assignmentId}`)
        
        const response = await axios.get(fileUrl, {
            responseType: 'arraybuffer'
        })
        const pdfBuffer = Buffer.from(response.data)
        
        // Fix — use default export correctly
        // New — pdf2json
const text = await new Promise<string>((resolve, reject) => {
    const pdfParser = new (PDFParser as any)(null, 1)
    
    pdfParser.on('pdfParser_dataError', (err: any) => reject(err))
    pdfParser.on('pdfParser_dataReady', () => {
        const text = pdfParser.getRawTextContent()
        resolve(text)
    })
    
    pdfParser.parseBuffer(pdfBuffer)
})
        
        if (!text || text.trim().length === 0) {
            throw new Error('No text could be extracted from this PDF')
        }
        
        console.log(`Extracted ${text.length} characters from PDF`)
        
        const chunks = chunkText(text)
        console.log(`Split into ${chunks.length} chunks`)
        
        try {
            await index.deleteMany({} as any)
        } catch (e) {
            // Ignore if no vectors exist
        }
        
        const embeddings = await openai.embeddings.create({
            model: 'text-embedding-3-small',
            input: chunks
        })
        
        // Fix — wrap vectors in { records: [...] } as required by new Pinecone SDK
        const vectors: PineconeRecord<RecordMetadata>[] = embeddings.data.map((embedding, i) => ({
            id: `${assignmentId}-chunk-${i}`,
            values: embedding.embedding,
            metadata: {
                assignmentId,
                courseId,
                text: chunks[i],
                chunkIndex: i
            }
        }))
        
        const batchSize = 100
for (let i = 0; i < vectors.length; i += batchSize) {
    const batch = vectors.slice(i, i + batchSize)
    await index.upsert({ records: batch } as any)
}
        
        console.log(`Successfully stored ${vectors.length} vectors for assignment ${assignmentId}`)
        return { success: true, chunksIngested: vectors.length }
        
    } catch (error: any) {
        console.error('Ingestion error:', error.message)
        throw error
    }
}

export const chat = async (
    question: string,
    assignmentId: string,
    conversationHistory: { role: 'user' | 'assistant', content: string }[] = [],
    assignmentMetadata?: { title: string, dueDate: string, description: string }
) => {
    try {
        const questionEmbedding = await openai.embeddings.create({
            model: 'text-embedding-3-small',
            input: question
        })
        
        const queryResponse = await index.query({
            vector: questionEmbedding.data[0].embedding,
            topK: 5,
            filter: { assignmentId: { '$eq': assignmentId } },
            includeMetadata: true
        })
        
        const relevantChunks = queryResponse.matches
            .map(match => match.metadata?.text as string)
            .filter(Boolean)
            .join('\n\n---\n\n')
        
            const systemPrompt = `You are Sage, an academic assistant for Meridian. 
            You help students understand and plan their assignments — you never complete assignments for them.
            
            You can:
            - Summarize what an assignment is asking
            - Explain specific requirements in plain language  
            - Extract and clarify deadlines
            - Suggest a study plan or approach
            - Answer factual questions about the assignment content
            - Explain concepts mentioned in the assignment
            
            You must NOT:
            - Write code, essays, or any graded deliverable for the student
            - Provide direct answers to assignment questions
            - Complete homework on the student's behalf
            - Generate solutions that could be submitted as the student's own work
            
            If a student asks you to solve or complete their assignment, politely decline and instead offer to explain the concept or help them plan their approach.
            
            ${assignmentMetadata ? `
            Assignment Details:
            - Title: ${assignmentMetadata.title}
            - Due Date: ${assignmentMetadata.dueDate}
            - Description: ${assignmentMetadata.description}
            ` : ''}
            
            Assignment Context from PDF:
            ${relevantChunks || 'No relevant context found for this question.'}`
        const messages: OpenAI.Chat.ChatCompletionMessageParam[] = [
            { role: 'system', content: systemPrompt },
            ...conversationHistory,
            { role: 'user', content: question }
        ]
        
        const completion = await openai.chat.completions.create({
            model: 'gpt-4o',
            messages,
            max_tokens: 500,
            temperature: 0.7
        })
        
        const response = completion.choices[0].message.content
        
        return {
            response,
            usage: completion.usage
        }
        
    } catch (error: any) {
        console.error('Chat error:', error.message)
        throw error
    }
}

export const summarizeAssignment = async (assignmentId: string) => {
    return await chat(
        'Please give me a brief summary of what this assignment is asking me to do. Keep it concise — 3 to 4 sentences.',
        assignmentId
    )
}