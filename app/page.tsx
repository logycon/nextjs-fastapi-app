'use client'

import {
  Box,
  Container,
  Heading,
  Text,
  Stack,
  Button,
  useColorMode,
  Card,
  CardBody,
  SimpleGrid,
  Textarea,
  useToast,
} from '@chakra-ui/react'
import { useState } from 'react'

export default function Home() {
  const { colorMode, toggleColorMode } = useColorMode()
  const [nextMessage, setNextMessage] = useState('')
  const [fastApiMessage, setFastApiMessage] = useState('')
  const [chatInput, setChatInput] = useState('')
  const [chatResponse, setChatResponse] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const toast = useToast()

  const fetchNextApi = async () => {
    const res = await fetch('/api/helloNextJs')
    const data = await res.json()
    setNextMessage(data.message)
  }

  const fetchFastApi = async () => {
    const res = await fetch('/api/py/helloFastApi')
    const data = await res.json()
    setFastApiMessage(data.message)
  }

  const handleChat = async () => {
    if (!chatInput.trim()) return
    
    setIsLoading(true)
    try {
      const res = await fetch('/api/py/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: chatInput }),
      })
      const data = await res.json()
      if (data.error) {
        toast({
          title: 'Error',
          description: data.error,
          status: 'error',
          duration: 5000,
          isClosable: true,
        })
      } else {
        setChatResponse(data.response)
        setChatInput('')
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to send message',
        status: 'error',
        duration: 5000,
        isClosable: true,
      })
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <Container maxW="container.xl" py={10}>
      <Stack spacing={8} align="center">
        <Heading size="2xl">Next.js + FastAPI + Chakra UI</Heading>
        
        <Button onClick={toggleColorMode}>
          Toggle {colorMode === 'light' ? 'Dark' : 'Light'} Mode
        </Button>

        <SimpleGrid columns={{ base: 1, md: 2 }} spacing={6} w="full">
          <Card variant="elevated" bg={colorMode === 'dark' ? 'gray.700' : 'white'}>
            <CardBody>
              <Stack spacing={4}>
                <Heading size="md">Ask Ollama</Heading>
                <Textarea
                  bg={colorMode === 'dark' ? 'gray.600' : 'white'}
                  value={chatInput}
                  onChange={(e) => setChatInput(e.target.value)}
                  placeholder="Type your message here..."
                />
                <Button
                  colorScheme="blue"
                  onClick={handleChat}
                  isLoading={isLoading}
                >
                  Send Message
                </Button>
                {chatResponse && (
                  <Text whiteSpace="pre-wrap">{chatResponse}</Text>
                )}
              </Stack>
            </CardBody>
          </Card>

          <Card variant="elevated" bg={colorMode === 'dark' ? 'gray.700' : 'white'}>
            <CardBody>
              <Stack spacing={4}>
                <Heading size="md">API Tests</Heading>
                <Text>{nextMessage || 'Click to fetch message'}</Text>
                <Button colorScheme="blue" onClick={fetchNextApi}>
                  Fetch Next.js Message
                </Button>
                <Text>{fastApiMessage || 'Click to fetch message'}</Text>
                <Button colorScheme="green" onClick={fetchFastApi}>
                  Fetch FastAPI Message
                </Button>
              </Stack>
            </CardBody>
          </Card>
        </SimpleGrid>
      </Stack>
    </Container>
  )
}
