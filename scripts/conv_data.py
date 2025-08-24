from datasets import Dataset, Value
from dotenv import load_dotenv

load_dotenv()

dataset = Dataset.from_parquet("./cargo_test_passed_eval.parquet")

dataset = dataset.remove_columns(["rust_code", "rust_test_list", "task_id"])

dataset = dataset.rename_column("rust_prompt", "question")

dataset = dataset.add_column("answer", [""] * len(dataset))

# Cast question column to string type to match hub schema
dataset = dataset.cast_column("question", Value("string"))

# push to hub
dataset.push_to_hub("rust_prompts", split="eval")
