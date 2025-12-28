import { useNavigate } from "react-router-dom";
import Button from "./Button";

export default function BackButton({ text = "Back" }) {
  const navigate = useNavigate();
  return (
    <Button
      type="back"
      onClick={(e) => {
        e.preventDefault();
        navigate(-1);
      }}
    >
      &larr; {text}
    </Button>
  );
}
