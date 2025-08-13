import tiktoken
import argparse

def count_tokens(file_path, model="gpt-3.5-turbo"):
    """
    Count the number of tokens in a text file using tiktoken.
    
    Args:
        file_path (str): Path to the text file
        model (str): The model to use for tokenization (default: "gpt-3.5-turbo")
        
    Returns:
        int: Number of tokens in the text
    """
    try:
        encoder = tiktoken.encoding_for_model(model)
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()
        
        tokens = encoder.encode(text)
        token_count = len(tokens)
        
        return token_count
    
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return None
    except Exception as e:
        print(f"Error: {str(e)}")
        return None

def main():
    parser = argparse.ArgumentParser(description='Count tokens in a text file')
    parser.add_argument('file_path', help='Path to the text file')
    parser.add_argument('--model', default='gpt-3.5-turbo', 
                      help='Model to use for tokenization (default: gpt-3.5-turbo)')
    args = parser.parse_args()
    
    token_count = count_tokens(args.file_path, args.model)
    
    if token_count is not None:
        print(f"Number of tokens: {token_count}")

if __name__ == "__main__":
    main()