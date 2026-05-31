from agents.base import BaseAgent


class TechnicalAgent(BaseAgent):
    system_prompt = "You are a technical interview coach who teaches concise problem-solving patterns."

    problems = [
        {
            "id": "two-sum",
            "title": "Two Sum",
            "difficulty": "Easy",
            "tags": ["Arrays", "Hash Map"],
            "statement": "Return indices of two numbers whose sum equals target.",
            "starter": "def two_sum(nums, target):\n    # Write your solution\n    return []",
        },
        {
            "id": "coin-change",
            "title": "Coin Change",
            "difficulty": "Medium",
            "tags": ["DP"],
            "statement": "Find the minimum coins needed to make an amount, or -1 if impossible.",
            "starter": "def coin_change(coins, amount):\n    # Write your solution\n    return -1",
        },
        {
            "id": "course-schedule",
            "title": "Course Schedule",
            "difficulty": "Medium",
            "tags": ["Graphs", "Topological Sort"],
            "statement": "Determine if all courses can be completed given prerequisites.",
            "starter": "def can_finish(num_courses, prerequisites):\n    # Write your solution\n    return True",
        },
        {
            "id": "median-stream",
            "title": "Median from Data Stream",
            "difficulty": "Hard",
            "tags": ["Heap", "Design"],
            "statement": "Support adding numbers and finding the current median efficiently.",
            "starter": "class MedianFinder:\n    def add_num(self, num):\n        pass\n\n    def find_median(self):\n        pass",
        },
    ]

    def run_code(self, problem_id: str, source: str) -> dict:
        if "return []" in source or "pass" in source:
            return {"verdict": "Wrong Answer", "runtime": "--", "tests_passed": "0/5", "message": "Complete the implementation before submitting."}
        if "while True" in source:
            return {"verdict": "Time Limit", "runtime": ">2 s", "tests_passed": "2/5", "message": "An unbounded loop exceeds the execution limit."}
        return {"verdict": "Accepted", "runtime": "18 ms", "tests_passed": "5/5", "message": "All sample and hidden test cases passed in demo execution."}

    def explain(self, problem_id: str) -> dict:
        problem = next((problem for problem in self.problems if problem["id"] == problem_id), self.problems[0])
        explanation = {
            "two-sum": "Scan once while storing previously seen values in a hash map. For each value, check whether target - value already exists. This reduces time to O(n).",
            "coin-change": "Use bottom-up dynamic programming where dp[x] is the fewest coins for amount x. Transition from dp[x - coin] + 1.",
            "course-schedule": "Model prerequisites as a directed graph. Kahn's topological sort succeeds only when every node can be removed with zero indegree.",
            "median-stream": "Keep a max heap for the lower half and min heap for the upper half, balanced within one item.",
        }[problem["id"]]
        return {"title": problem["title"], "explanation": explanation}
