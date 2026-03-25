export interface YouTubeVideo {
    id: string;
    title: string;
    description: string;
    thumbnailUrl: string;
    publishedAt: string;
}

const API_KEY = import.meta.env.VITE_YOUTUBE_API_KEY;
const CHANNEL_ID = import.meta.env.VITE_YOUTUBE_CHANNEL_ID;

export async function fetchLatestVideos(maxResults = 9): Promise<YouTubeVideo[]> {
    if (!API_KEY || !CHANNEL_ID) {
        console.warn('YouTube API credentials not found in environment variables.');
        return [];
    }

    try {
        const url = `https://www.googleapis.com/youtube/v3/search?key=${API_KEY}&channelId=${CHANNEL_ID}&part=snippet,id&order=date&maxResults=${maxResults}&type=video`;
        const response = await fetch(url);
        
        if (!response.ok) {
            console.error('Failed to fetch YouTube videos:', response.statusText);
            return [];
        }

        const data = await response.json();
        
        return data.items.map((item: any) => ({
            id: item.id.videoId,
            title: item.snippet.title,
            description: item.snippet.description,
            thumbnailUrl: item.snippet.thumbnails.high?.url || item.snippet.thumbnails.medium?.url || item.snippet.thumbnails.default?.url,
            publishedAt: item.snippet.publishedAt,
        }));
    } catch (error) {
        console.error('Error fetching YouTube videos:', error);
        return [];
    }
}
