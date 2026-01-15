<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get user conversations
     */
    public function getConversations(Request $request)
    {
        $userId = $request->user()->id;
        $userType = $request->user()->getMorphClass();

        $conversations = Conversation::with(['trainer', 'trainee', 'lastMessage'])
            ->where(function ($query) use ($userId, $userType) {
                if ($userType === 'trainer') {
                    $query->where('trainer_id', $userId);
                } else {
                    $query->where('trainee_id', $userId);
                }
            })
            ->orderBy('last_message_at', 'desc')
            ->get()
            ->map(function ($conversation) use ($userId, $userType) {
                return [
                    'id' => $conversation->id,
                    'trainer' => [
                        'id' => $conversation->trainer->id,
                        'name' => $conversation->trainer->name,
                        'avatar' => $conversation->trainer->avatar,
                        'specialization' => $conversation->trainer->specialization,
                    ],
                    'trainee' => [
                        'id' => $conversation->trainee->id,
                        'name' => $conversation->trainee->name,
                        'avatar' => $conversation->trainee->avatar,
                    ],
                    'last_message' => $conversation->lastMessage?->content,
                    'last_message_time' => $conversation->last_message_at,
                    'unread_count' => $conversation->messages()
                        ->where('is_read', false)
                        ->where('sender_type', '!=', $userType)
                        ->count(),
                ];
            });

        return response()->json([
            'success' => true,
            'conversations' => $conversations,
        ]);
    }

    /**
     * Get messages for a conversation
     */
    public function getMessages(Request $request, $conversationId)
    {
        $limit = $request->get('limit', 50);
        $offset = $request->get('offset', 0);

        $messages = Message::where('conversation_id', $conversationId)
            ->orderBy('created_at', 'desc')
            ->skip($offset)
            ->take($limit)
            ->get()
            ->reverse()
            ->values()
            ->map(function ($message) {
                return [
                    'id' => $message->id,
                    'sender_id' => $message->sender_id,
                    'sender_type' => $message->sender_type,
                    'content' => $message->content,
                    'type' => $message->type,
                    'metadata' => $message->metadata,
                    'is_read' => $message->is_read,
                    'created_at' => $message->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'messages' => $messages,
        ]);
    }

    /**
     * Send a message
     */
    public function sendMessage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'conversation_id' => 'required|exists:conversations,id',
            'content' => 'required|string',
            'type' => 'in:text,image,voice,file',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        $message = Message::create([
            'conversation_id' => $request->conversation_id,
            'sender_type' => $user->getMorphClass(),
            'sender_id' => $user->id,
            'content' => $request->content,
            'type' => $request->type ?? 'text',
            'metadata' => $request->metadata,
        ]);

        // Update conversation last message time
        Conversation::where('id', $request->conversation_id)
            ->update(['last_message_at' => now()]);

        // TODO: Send push notification to receiver
        // TODO: Broadcast via WebSocket

        return response()->json([
            'success' => true,
            'message' => [
                'id' => $message->id,
                'sender_id' => $message->sender_id,
                'sender_type' => $message->sender_type,
                'content' => $message->content,
                'type' => $message->type,
                'metadata' => $message->metadata,
                'created_at' => $message->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Create a new conversation
     */
    public function createConversation(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'trainer_id' => 'required|exists:trainers,id',
            'trainee_id' => 'required|exists:trainees,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $conversation = Conversation::firstOrCreate([
            'trainer_id' => $request->trainer_id,
            'trainee_id' => $request->trainee_id,
        ]);

        return response()->json([
            'success' => true,
            'conversation' => $conversation,
        ], 201);
    }

    /**
     * Mark messages as read
     */
    public function markAsRead(Request $request, $conversationId)
    {
        $user = $request->user();
        $userType = $user->getMorphClass();

        Message::where('conversation_id', $conversationId)
            ->where('sender_type', '!=', $userType)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json(['success' => true]);
    }
}
